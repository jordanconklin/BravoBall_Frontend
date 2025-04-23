//
//  SessionGeneratorModel.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/31/25.
//


import SwiftUI
import Foundation
import SwiftKeychainWrapper

// MARK: Session model
class SessionGeneratorModel: ObservableObject {
    
    @ObservedObject var appModel: MainAppModel  // Add this
    
    // Add loading state
    @Published var isRegeneratingSession: Bool = false
    
    let cacheManager = CacheManager.shared
    private var lastSyncTime: Date = Date()
    private let syncDebounceInterval: TimeInterval = 2.0 // 2 seconds
    var hasUnsavedChanges = false
    var autoSaveTimer: Timer?
    var isLoggingOut = false  // Add flag to prevent caching during logout
    var isInitialLoad = true  // Add this flag
    // Track backend IDs for each group
    var groupBackendIds: [UUID: Int] = [:]
    // Track the backend ID for the liked group
    var likedGroupBackendId: Int?
    
    
    
    // MARK: Filter Types
    
    
    @Published var selectedTime: String?
    @Published var selectedEquipment: Set<String> = []
    @Published var selectedTrainingStyle: String?
    @Published var selectedLocation: String?
    @Published var selectedDifficulty: String?
    @Published var selectedSkills: Set<String> = [] {
        didSet {
            updateDrills()
        }
    }
    
    
    
    // MARK: Local Data Storage
    
    @Published var selectedDrills: [DrillModel] = []
    @Published var selectedDrillForEditing: EditableDrillModel?
    @Published var recommendedDrills: [DrillModel] = []
    
    // Session Drills storage
    @Published var orderedSessionDrills: [EditableDrillModel] = [] {
        didSet { 
            if !isInitialLoad && !isLoggingOut {
                markAsNeedingSave(change: .orderedDrills)
            }
        }
    }
    // Saved Drills storage
    @Published var savedDrills: [GroupModel] = [] {
        didSet {
            if !isInitialLoad && !isLoggingOut {
                markAsNeedingSave(change: .savedDrills)
            }
        }
    }
    
    // Liked drills storage
    @Published var likedDrillsGroup: GroupModel = GroupModel(
        id: UUID(), // Will be properly initialized in init()
        name: "Liked Drills",
        description: "Your favorite drills",
        drills: []
    ) {
        didSet { 
            markAsNeedingSave(change: .likedDrills)
        }
    }
    
    // Saved filters storage
    @Published var allSavedFilters: [SavedFiltersModel] = [] {
        didSet {
            if !isInitialLoad && !isLoggingOut {
                markAsNeedingSave(change: .savedFilters)
            }
        }
    }
    // didset in savedFilters func
    
    

    
    
    // MARK: Init
    
    init(appModel: MainAppModel, onboardingData: OnboardingModel.OnboardingData) {
        self.appModel = appModel
        
        // Check if we just signed out and/or signed in with a new user
        let currentUser = KeychainWrapper.standard.string(forKey: "userEmail") ?? "no user"
        let lastUser = UserDefaults.standard.string(forKey: "lastActiveUser") ?? ""
        
        if currentUser != lastUser {
            print("👤 User change detected: '\(lastUser)' → '\(currentUser)'")
            // Clear any leftover data from previous user
            clearUserData()
            
            // Save current user as last active
            UserDefaults.standard.set(currentUser, forKey: "lastActiveUser")
        }
        
        // Only set these values if they're not already loaded from cache
        if selectedDifficulty == nil {
            selectedDifficulty = onboardingData.trainingExperience.lowercased()
        }
        if selectedLocation == nil && !onboardingData.trainingLocation.isEmpty {
            selectedLocation = onboardingData.trainingLocation.first
        }
        if selectedEquipment.isEmpty {
            selectedEquipment = Set(onboardingData.availableEquipment)
        }
        if selectedTime == nil {
            switch onboardingData.dailyTrainingTime {
            case "Less than 15 minutes": selectedTime = "15min"
            case "15-30 minutes": selectedTime = "30min"
            case "30-60 minutes": selectedTime = "1h"
            case "1-2 hours": selectedTime = "1h30"
            case "More than 2 hours": selectedTime = "2h+"
            default: selectedTime = "1h"
            }
        }
        
        // Setup auto-save timer
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.saveChanges()
        }
        
        // Add observer for user logout
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserLogout),
            name: Notification.Name("UserLoggedOut"),
            object: nil
        )
                
    }
    
    deinit {
        autoSaveTimer?.invalidate()
        saveChanges() // Final save on deinit
        // Remove notification observer
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    
    // User logout and clearing of data
    @objc private func handleUserLogout(notification: Notification) {
        if let previousEmail = notification.userInfo?["previousEmail"] as? String {
            print("📣 SessionGeneratorModel received logout notification for user: \(previousEmail)")
        } else {
            print("📣 SessionGeneratorModel received logout notification")
        }
        
        // Set logging out flag before clearing data
        isLoggingOut = true
        
        // Clear all user data
        clearUserData()
        
        // Reset logging out flag after clearing
        isLoggingOut = false
    }
    
    
    
    // MARK: Data change syncage
    struct DataChangeTracker {
        var orderedDrillsChanged: Bool = false
        var savedFiltersChanged: Bool = false
        var progressHistoryChanged: Bool = false
        var likedDrillsChanged: Bool = false
        var savedDrillsChanged: Bool = false
        var completedSessionsChanged: Bool = false
        
        mutating func reset() {
            orderedDrillsChanged = false
            savedFiltersChanged = false
            progressHistoryChanged = false
            likedDrillsChanged = false
            savedDrillsChanged = false
            completedSessionsChanged = false
        }
        
        var hasAnyChanges: Bool {
            return orderedDrillsChanged || 
                   savedFiltersChanged || 
                   progressHistoryChanged || 
                   likedDrillsChanged || 
                   savedDrillsChanged ||
                   completedSessionsChanged
        }
    }
    
    var changeTracker = DataChangeTracker()
    
    
    
    // Tasks run if there are unsaved changes
    func markAsNeedingSave(change: DataChange) {
        // Don't mark changes during logout
        guard !isLoggingOut else { return }
        
        hasUnsavedChanges = true
        
        switch change {
        case .orderedDrills:
            changeTracker.orderedDrillsChanged = true
            cacheOrderedDrills()
        case .savedFilters:
            changeTracker.savedFiltersChanged = true
            cacheFilterGroups(name: "")
        case .progressHistory:
            changeTracker.progressHistoryChanged = true
            // Progress history is handled by MainAppModel
        case .likedDrills:
            changeTracker.likedDrillsChanged = true
            cacheLikedDrills()
        case .savedDrills:
            changeTracker.savedDrillsChanged = true
            cacheSavedDrills()
        case .completedSessions:
            changeTracker.completedSessionsChanged = true
        }
    }
    
    enum DataChange {
        case orderedDrills
        case savedFilters
        case progressHistory
        case likedDrills
        case savedDrills
        case completedSessions
    }
    
    // MARK: - Saving and Syncing
    // saves changes while user is using the app
    func saveChanges() {
        guard changeTracker.hasAnyChanges else { return }
        
        Task {
            do {
                // Only sync what has changed
                if changeTracker.orderedDrillsChanged {
                    try await DataSyncService.shared.syncOrderedSessionDrills(
                        sessionDrills: orderedSessionDrills
                    )
                    cacheOrderedDrills()
                }
                if changeTracker.savedFiltersChanged {
                    try await SavedFiltersService.shared.syncSavedFilters(
                        savedFilters: allSavedFilters
                    )
                    // caching performed in saveFiltersInGroup function when user saves filter
                    
                }
                
                // TODO: right now the changeTracker is set on progress history variables directly in mainappmodel w/ didSet, see if can implement changeTracker to here, may have to reorganize main and ses models
//                if changeTracker.progressHistoryChanged {
//                    try await DataSyncService.shared.syncProgressHistory(
//                        currentStreak: appModel.currentStreak,
//                        highestStreak: appModel.highestStreak,
//                        completedSessionsCount: appModel.countOfFullyCompletedSessions
//                    )
//                    appModel.cacheCurrentStreak()
//                    appModel.cacheHighestStreak()
//                    appModel.cacheCompletedSessionsCount()
//                }
                
                // Sync both liked drills and saved drills together if either has changed
                if changeTracker.likedDrillsChanged || changeTracker.savedDrillsChanged {
                    try await DataSyncService.shared.syncAllDrillGroups(
                        savedGroups: savedDrills,
                        likedGroup: likedDrillsGroup
                    )
                    // Cache after successful sync
                    cacheSavedDrills()
                    cacheLikedDrills()
                }
                
                // TODO: right now the changeTracker is set on allCompletedSessions directly in mainappmodel, see if can implement changeTracker to here, may have to reorganize main and ses models
//                if changeTracker.completedSessionsChanged {
//                    let completedDrills = orderedSessionDrills.filter { $0.isCompleted }.count
//                    try await DataSyncService.shared.syncCompletedSession(
//                        date: Date(),
//                        drills: orderedSessionDrills,
//                        totalCompleted: completedDrills,
//                        total: orderedSessionDrills.count
//                    )
//                    appModel.cacheCompletedSessions()
//                    
//                }
                
                await MainActor.run {
                    changeTracker.reset()
                    hasUnsavedChanges = false
                }
            } catch {
                print("❌ Error syncing data: \(error)")
                // Keep change flags set so we can retry on next save
            }
        }
    }
    
    
    // Test data for drills with specific sub-skills
    static let testDrills: [DrillModel] = [
        DrillModel(
            title: "Short Passing Drill",
            skill: "Passing",
            sets: 4,
            reps: 10,
            duration: 15,
            description: "Practice accurate short passes with a partner or wall.",
            tips: ["Keep the ball on the ground", "Use inside of foot", "Follow through towards target"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "High Intensity",
            difficulty: "Beginner"
        ),
        DrillModel(
            title: "Long Passing Practice",
            skill: "Passing",
            sets: 3,
            reps: 8,
            duration: 20,
            description: "Improve your long-range passing accuracy.",
            tips: ["Lock ankle", "Follow through", "Watch ball contact"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "Medium Intensity",
            difficulty: "Intermediate"
        ),
        DrillModel(
            title: "Through Ball Training",
            skill: "Passing",
            sets: 4,
            reps: 6,
            duration: 15,
            description: "Practice timing and weight of through passes.",
            tips: ["Look for space", "Time the pass", "Weight it properly"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "Medium Intensity",
            difficulty: "Intermediate"
        ),
        DrillModel(
            title: "Power Shot Practice",
            skill: "Shooting",
            sets: 3,
            reps: 5,
            duration: 20,
            description: "Work on powerful shots on goal.",
            tips: ["Plant foot beside ball", "Strike with laces", "Follow through"],
            equipment: ["Soccer ball", "Goal"],
            trainingStyle: "High Intensity",
            difficulty: "Intermediate"
        ),
        DrillModel(
            title: "1v1 Dribbling Skills",
            skill: "Dribbling",
            sets: 4,
            reps: 8,
            duration: 15,
            description: "Master close ball control and quick direction changes.",
            tips: ["Keep ball close", "Use both feet", "Change pace"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "High Intensity",
            difficulty: "Intermediate"
        )
    ]

    
    // Define Preferences struct for caching
    struct Preferences: Codable {
        var selectedTime: String?
        var selectedEquipment: [String]
        var selectedTrainingStyle: String?
        var selectedLocation: String?
        var selectedDifficulty: String?
        
        init(from model: SessionGeneratorModel) {
            self.selectedTime = model.selectedTime
            self.selectedEquipment = Array(model.selectedEquipment)
            self.selectedTrainingStyle = model.selectedTrainingStyle
            self.selectedLocation = model.selectedLocation
            self.selectedDifficulty = model.selectedDifficulty
        }
    }

    // MARK: - Session Generation

    /// Generate a session using the current preferences
    func generateSession() async throws -> SessionResponse {
        let url = URL(string: "\(AppSettings.baseURL)/api/session/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using auth token: \(token)")
        } else {
            print("⚠️ No auth token found!")
            throw URLError(.userAuthenticationRequired)
        }
        
        print("📤 Generating session with current preferences")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw URLError(.badServerResponse)
        }
        
        print("📥 Response status code: \(httpResponse.statusCode)")
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let sessionResponse = try decoder.decode(SessionResponse.self, from: data)
            print("✅ Successfully generated session with \(sessionResponse.drills.count) drills")
            return sessionResponse
        case 401:
            print("❌ Unauthorized - Invalid or expired token")
            throw URLError(.userAuthenticationRequired)
        case 404:
            print("❌ Endpoint not found")
            throw URLError(.badURL)
        default:
            print("❌ Unexpected status code: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
            throw URLError(.badServerResponse)
        }
    }

    /// Generate a session with custom preferences without saving them
    func generateSessionWithPreferences() async throws -> SessionResponse {
        let url = URL(string: "\(AppSettings.baseURL)/api/session/generate-with-preferences")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using auth token: \(token)")
        } else {
            print("⚠️ No auth token found!")
            throw URLError(.userAuthenticationRequired)
        }
        
        // Convert duration string to minutes
        let duration: Int
        switch selectedTime {
        case "15min": duration = 15
        case "30min": duration = 30
        case "1h": duration = 60
        case "1h30": duration = 90
        case "2h+": duration = 120
        default: duration = 30
        }
        
        // Create preferences dictionary
        let preferences: [String: Any] = [
            "duration": duration,
            "available_equipment": Array(selectedEquipment),
            "training_style": selectedTrainingStyle?.lowercased().replacingOccurrences(of: " ", with: "_") ?? "medium_intensity",
            "training_location": selectedLocation?.lowercased().replacingOccurrences(of: " ", with: "_") ?? "full_field",
            "difficulty": selectedDifficulty?.lowercased() ?? "beginner",
            "target_skills": Array(selectedSkills).map { $0.lowercased().replacingOccurrences(of: " ", with: "_") }
        ]
        
        print("📤 Generating session with preferences: \(preferences)")
        
        // Encode request body
        request.httpBody = try JSONSerialization.data(withJSONObject: preferences)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw URLError(.badServerResponse)
        }
        
        print("📥 Response status code: \(httpResponse.statusCode)")
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let sessionResponse = try decoder.decode(SessionResponse.self, from: data)
            print("✅ Successfully generated session with \(sessionResponse.drills.count) drills")
            return sessionResponse
        case 401:
            print("❌ Unauthorized - Invalid or expired token")
            throw URLError(.userAuthenticationRequired)
        case 404:
            print("❌ Endpoint not found")
            throw URLError(.badURL)
        case 422:
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ Validation error: \(responseString)")
            }
            throw URLError(.badServerResponse)
        default:
            print("❌ Unexpected status code: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
            throw URLError(.badServerResponse)
        }
    }

    // Add regenerate session function
    func regenerateSession() async {
        await MainActor.run { isRegeneratingSession = true }
        
        do {
            // Use generateSessionWithPreferences to use current filter selections
            let sessionResponse = try await generateSessionWithPreferences()
            await MainActor.run {
                loadInitialSession(from: sessionResponse)
                isRegeneratingSession = false
            }
        } catch {
            print("❌ Error regenerating session: \(error)")
            await MainActor.run { isRegeneratingSession = false }
        }
    }

}


