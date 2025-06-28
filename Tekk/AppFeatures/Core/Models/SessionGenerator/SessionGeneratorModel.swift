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
    @Published var isLoadingDrills: Bool = false
    
    let cacheManager = CacheManager.shared
    private var lastSyncTime: Date = Date()
    private let syncDebounceInterval: TimeInterval = 2.0 // 2 seconds
    var hasUnsavedChanges = false
    var autoSaveTimer: Timer?
    var isLoggingOut = false  // Add flag to prevent caching during logout
    var isInitialLoad = false  // Add this flag
    // Track backend IDs for each group
    var groupBackendIds: [UUID: Int] = [:]
    // Track the backend ID for the liked group
    var likedGroupBackendId: Int?
    
    // Add a property to track the current session ID
    var currentSessionId: Int?
    
    private var preferenceUpdateTask: Task<Void, Never>?
    private var isOnboarding = false
    
    func schedulePreferenceUpdate() {
        // If we're in onboarding, update immediately
        if isOnboarding {
            Task {
                await syncPreferencesWithBackend()
            }
            return
        }
        
        // Cancel any existing update task
        preferenceUpdateTask?.cancel()
        
        // Create a new task
        preferenceUpdateTask = Task {
            // Wait for 0.5 seconds to allow for multiple rapid changes
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Only proceed if the task hasn't been cancelled
            guard !Task.isCancelled else { return }
            
            // Perform the update
            await syncPreferencesWithBackend()
        }
    }
    
    
    // Computed property to get the correct icon name
    func skillIconName(for skill: String) -> String {
        let normalizedSkill = skill
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "_", with: "")
        
        let skillCategory = SessionGeneratorView.skillCategories.first { category in
            let normalizedCategoryName = category.name
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "_", with: "")
            return normalizedCategoryName == normalizedSkill
        }
        return skillCategory?.icon ?? "figure.soccer"
    }
    
    
    // MARK: Filter and Skill Selection
    
    
    
    @Published var selectedTime: String? {
        didSet {
            print("[DEBUG] selectedTime changed to: \(String(describing: selectedTime))")
            if !isInitialLoad && !isLoggingOut {
                schedulePreferenceUpdate()
            }
            print("\(isInitialLoad) and \(isLoggingOut)")
        }
    }

    @Published var selectedEquipment: Set<String> = [] {
        didSet {
            print("[DEBUG] selectedEquipment changed to: \(selectedEquipment)")
            if !isInitialLoad && !isLoggingOut {
                schedulePreferenceUpdate()
            }
        }
    }

    @Published var selectedTrainingStyle: String? {
        didSet {
            print("[DEBUG] selectedTrainingStyle changed to: \(String(describing: selectedTrainingStyle))")
            if !isInitialLoad && !isLoggingOut {
                schedulePreferenceUpdate()
            }
        }
    }

    @Published var selectedLocation: String? {
        didSet {
            print("[DEBUG] selectedLocation changed to: \(String(describing: selectedLocation))")
            if !isInitialLoad && !isLoggingOut {
                schedulePreferenceUpdate()
            }
        }
    }

    @Published var selectedDifficulty: String? {
        didSet {
            print("[DEBUG] selectedDifficulty changed to: \(String(describing: selectedDifficulty))")
            if !isInitialLoad && !isLoggingOut {
                schedulePreferenceUpdate()
            }
        }
    }

    // update by selected skills
    @Published var selectedSkills: Set<String> = []
    @Published var originalSelectedSkills: Set<String> = []
    
    
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
//        
//        if currentUser != lastUser {
//            print("👤 User change detected: '\(lastUser)' → '\(currentUser)'")
//            // Clear any leftover data from previous user
//            clearUserData()
//            
//            // Save current user as last active
//            UserDefaults.standard.set(currentUser, forKey: "lastActiveUser")
//        }
//        print("OnboardingData at model init: \(onboardingData)")
        
        
        
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
            return
                   orderedDrillsChanged ||
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
        print("DEBUG markAsNeedingSave")
        
        hasUnsavedChanges = true
        
        switch change {
        case .userPreferences:
            // preferences will be saved through this function
            Task {
                await syncPreferencesWithBackend()
            }
        case .orderedDrills:
            changeTracker.orderedDrillsChanged = true
            cacheOrderedDrills()
//        case .userPreferences:
//            // Add preference syncing when filters change
////            Task {
////                await syncPreferencesWithBackend()
////            }
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
        case userPreferences
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
//                    cacheOrderedDrills()
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
                
                if changeTracker.completedSessionsChanged {
                    let completedDrills = orderedSessionDrills.filter { $0.isCompleted }.count
                    try await DataSyncService.shared.syncCompletedSession(
                        date: Date(),
                        drills: orderedSessionDrills,
                        totalCompleted: completedDrills,
                        total: orderedSessionDrills.count
                    )
                    appModel.cacheCompletedSessions()
                }
                
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
            subSkills: ["short_passing"],
            sets: 4,
            reps: 10,
            duration: 15,
            description: "Practice accurate short passes with a partner or wall.",
            instructions: [""],
            tips: ["Keep the ball on the ground", "Use inside of foot", "Follow through towards target"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "High Intensity",
            difficulty: "Beginner",
            videoUrl: "www.example.com"
        ),
        DrillModel(
            title: "Short Passing Drill Two",
            skill: "Passing",
            subSkills: ["short_passing"],
            sets: 4,
            reps: 10,
            duration: 15,
            description: "Practice accurate short passes with a partner or wall.",
            instructions: [""],
            tips: ["Keep the ball on the ground", "Use inside of foot", "Follow through towards target"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "High Intensity",
            difficulty: "Beginner",
            videoUrl: "www.example.com"
        ),
        DrillModel(
            title: "Short Passing Drill Three",
            skill: "Passing",
            subSkills: ["short_passing"],
            sets: 4,
            reps: 10,
            duration: 15,
            description: "Practice accurate short passes with a partner or wall.",
            instructions: [""],
            tips: ["Keep the ball on the ground", "Use inside of foot", "Follow through towards target"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "High Intensity",
            difficulty: "Beginner",
            videoUrl: "www.example.com"
        ),
        DrillModel(
            title: "Short Passing Four",
            skill: "Passing",
            subSkills: ["short_passing"],
            sets: 4,
            reps: 10,
            duration: 15,
            description: "Practice accurate short passes with a partner or wall.",
            instructions: [""],
            tips: ["Keep the ball on the ground", "Use inside of foot", "Follow through towards target"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "High Intensity",
            difficulty: "Beginner",
            videoUrl: "www.example.com"
        ),
        DrillModel(
            title: "Long Passing Practice",
            skill: "Passing",
            subSkills: ["long_passing"],
            sets: 3,
            reps: 8,
            duration: 20,
            description: "Improve your long-range passing accuracy.",
            instructions: [""],
            tips: ["Lock ankle", "Follow through", "Watch ball contact"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "Medium Intensity",
            difficulty: "Intermediate",
            videoUrl: "www.example.com"
        ),
        DrillModel(
            title: "Through Ball Training",
            skill: "Passing",
            subSkills: ["long_passing"],
            sets: 4,
            reps: 6,
            duration: 15,
            description: "Practice timing and weight of through passes.",
            instructions: [""],
            tips: ["Look for space", "Time the pass", "Weight it properly"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "Medium Intensity",
            difficulty: "Intermediate",
            videoUrl: "www.example.com"
        ),
        DrillModel(
            title: "Power Shot Practice",
            skill: "Shooting",
            subSkills: ["power_shots"],
            sets: 3,
            reps: 5,
            duration: 20,
            description: "Work on powerful shots on goal.",
            instructions: [""],
            tips: ["Plant foot beside ball", "Strike with laces", "Follow through"],
            equipment: ["Soccer ball", "Goal"],
            trainingStyle: "High Intensity",
            difficulty: "Intermediate",
            videoUrl: "www.example.com"
        ),
        DrillModel(
            title: "1v1 Dribbling Skills",
            skill: "Dribbling",
            subSkills: ["1v1_moves"],
            sets: 4,
            reps: 8,
            duration: 15,
            description: "Master close ball control and quick direction changes.",
            instructions: [""],
            tips: ["Keep ball close", "Use both feet", "Change pace"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "High Intensity",
            difficulty: "Intermediate",
            videoUrl: "www.example.com"
        )
    ]

    
    // Define Preferences struct for caching
    struct Preferences: Codable {
        var selectedTime: String?
        var selectedEquipment: [String]
        var selectedTrainingStyle: String?
        var selectedLocation: String?
        var selectedDifficulty: String?
        
        init(from sessionGeneratorModel: SessionGeneratorModel) {
            self.selectedTime = sessionGeneratorModel.selectedTime
            self.selectedEquipment = Array(sessionGeneratorModel.selectedEquipment)
            self.selectedTrainingStyle = sessionGeneratorModel.selectedTrainingStyle
            self.selectedLocation = sessionGeneratorModel.selectedLocation
            self.selectedDifficulty = sessionGeneratorModel.selectedDifficulty
        }
    }

    func loadInitialSession(from sessionResponse: SessionResponse) {
        Task {
            await MainActor.run {
                isLoadingDrills = true
            }
            
            print("\n🔄 Loading initial session with \(sessionResponse.drills.count) drills")
            self.currentSessionId = sessionResponse.sessionId
            print("✅ Current session ID: \(currentSessionId)")
            
            // Instead of directly setting selectedSkills, map the focus areas to their full skill strings
            let newSkills = Set(sessionResponse.focusAreas.compactMap { category in
                // Find any existing skills that match this category
                selectedSkills.first { $0.starts(with: "\(category)-") }
            })
            
            // Only update if we found matching skills
            if !newSkills.isEmpty {
                selectedSkills = newSkills
                print("✅ Updated focus areas: \(selectedSkills.joined(separator: ", "))")
            }
            
            // Clear any existing drills
            orderedSessionDrills.removeAll()
            
            // Convert API drills to app's drill models and add them to orderedDrills
            var processedCount = 0
            for apiDrill in sessionResponse.drills {
                do {
                    let drillModel = apiDrill.toDrillModel()
                    print("[Session] Drill loaded: \(drillModel.title), videoUrl: \(drillModel.videoUrl ?? "nil")")
                    // Create an editable drill model
                    let editableDrill = EditableDrillModel(
                        drill: drillModel,
                        setsDone: 0,
                        totalSets: drillModel.sets,
                        totalReps: drillModel.reps,
                        totalDuration: drillModel.duration,
                        isCompleted: false
                    )
                    // Add to ordered drills
                    orderedSessionDrills.append(editableDrill)
                    processedCount += 1
                }
            }
            
            print("✅ Processed \(processedCount) drills for session")
            
            // Explicitly save to cache since we're in initial load
            cacheOrderedDrills()
            saveChanges()
            
            await MainActor.run {
                isLoadingDrills = false
            }
        }
    }

    
    

    // Update the syncPreferencesWithBackend method
    func syncPreferencesWithBackend() async {
        await MainActor.run {
            isLoadingDrills = true
        }
        defer {
            Task { @MainActor in
                isLoadingDrills = false
            }
        }
        do {
            try await PreferencesUpdateService.shared.updatePreferences(
                time: selectedTime,
                equipment: selectedEquipment,
                trainingStyle: selectedTrainingStyle,
                location: selectedLocation,
                difficulty: selectedDifficulty,
                skills: selectedSkills,
                sessionModel: self,
                isOnboarding: isOnboarding
            )
            print("✅ Successfully synced preferences with backend")
        } catch URLError.timedOut {
            print("⏱️ Request debounced – too soon since last request")
        } catch {
            print("❌ Failed to sync preferences with backend: \(error)")
        }
    }
    
    // Load preferences from backend
    func loadPreferencesFromBackend() async {
        do {
            let preferences = try await PreferencesUpdateService.shared.fetchPreferences()
            
            // Update preferences on the main thread
            await MainActor.run {
                // Convert duration to time string
                selectedTime = PreferencesUpdateService.shared.convertMinutesToTimeString(preferences.duration ?? 0)
                
                // Update equipment
                selectedEquipment = Set(preferences.availableEquipment ?? [])
                
                // Update other preferences
                selectedTrainingStyle = preferences.trainingStyle
                selectedLocation = preferences.trainingLocation
                selectedDifficulty = preferences.difficulty
                
                // Convert backend skills to frontend format
                selectedSkills = Set(preferences.targetSkills ?? [])
                
                print("✅ Successfully loaded preferences from backend")
            }
            
            // Cache the updated preferences
            cachePreferences()
        } catch {
            print("❌ Failed to load preferences from backend: \(error)")
        }
    }
    
    // Cache current preferences
    func cachePreferences() {
        let preferences = Preferences(from: self)
        cacheManager.cache(preferences, forKey: .filterGroupsCase)
        print("✅ Cached preferences")
    }

    // MARK: Default subskill mapping
    static let defaultSubskills: [String: String] = [
        "Passing": "Short passing",
        "Shooting": "Power shots",
        "Dribbling": "1v1 moves",
        "Defending": "Tackling",
        "First touch": "First touch",
        "Fitness": "Conditioning"
    ]

    @MainActor
    func prefillSelectedSkills(from onboardingData: OnboardingModel.OnboardingData) async {
        isOnboarding = true
        let skillsToImprove = onboardingData.areasToImprove
        let prefilledSubskillsAfterOnboarding = Set(skillsToImprove.compactMap { skill in
            if let subskill = SessionGeneratorModel.defaultSubskills[skill] {
                return "\(subskill)"
            }
            return nil
        })
        print("✅ Identified subskills to improve: \(prefilledSubskillsAfterOnboarding)")
        selectedSkills = prefilledSubskillsAfterOnboarding
        print("Prefilled subskills after onboarding: \(selectedSkills)")
    }
    
    @MainActor
    func prefillPreferences(from onboardingData: OnboardingModel.OnboardingData) async {
        isOnboarding = true
        // --- TIME ---
        let timeMap: [String: String] = [
            "Less than 15 minutes": "15min",
            "15-30 minutes": "30min",
            "30-60 minutes": "1h",
            "1-2 hours": "1h30",
            "More than 2 hours": "2h+"
        ]
    
        selectedTime = timeMap[onboardingData.dailyTrainingTime] ?? "30min"

        // --- EQUIPMENT ---
        let allowedEquipment = ["soccer ball", "cones", "goal"]
        let selectedEquipmentSet = Set(onboardingData.availableEquipment.map { $0.lowercased() }
            .filter { allowedEquipment.contains($0) }
            .map { $0 == "goal" ? "goal" : $0 }) // normalize
        
        // If no equipment was selected, default to soccer ball
        selectedEquipment = selectedEquipmentSet.isEmpty ? ["soccer ball"] : selectedEquipmentSet

        // --- TRAINING STYLE ---
        let styleMap: [String: String] = [
            "Beginner": "medium intensity",
            "Intermediate": "medium intensity",
            "Advanced": "high intensity",
            "Professional": "game prep",
            "Rest day": "rest day"
        ]
        selectedTrainingStyle = styleMap[onboardingData.trainingExperience] ?? "medium intensity"

        // --- LOCATION ---
        let locationMap: [String: String] = [
            "At a soccer field with goals": "location with goals",
            "At home (backyard or indoors)": "small space",
            "At a park or open field": "full field",
            "At a gym or indoor court": "medium field"
        ]
        selectedLocation = onboardingData.trainingLocation
            .compactMap { locationMap[$0] }
            .first ?? "full field"

        // --- DIFFICULTY ---
        let difficultyMap: [String: String] = [
            "Beginner": "beginner",
            "Intermediate": "intermediate",
            "Advanced": "advanced",
            "Professional": "advanced"
        ]
        selectedDifficulty = difficultyMap[onboardingData.position] ?? "medium"

        print("✅ Prefilled preferences from onboarding data:")

        // After all preferences are set, update isOnboarding to false
        isOnboarding = false
    }

}


