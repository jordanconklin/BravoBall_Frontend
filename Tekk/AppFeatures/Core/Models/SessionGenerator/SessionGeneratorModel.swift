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
    
    
    
    
    
    
    // MARK: Filter and Skill Selection
    
    
    
    @Published var selectedTime: String? {
        didSet {
            if !isInitialLoad && !isLoggingOut {
                markAsNeedingSave(change: .userPreferences)
            }
        }
    }

    @Published var selectedEquipment: Set<String> = [] {
        didSet {
            if !isInitialLoad && !isLoggingOut {
                markAsNeedingSave(change: .userPreferences)
            }
        }
    }

    @Published var selectedTrainingStyle: String? {
        didSet {
            if !isInitialLoad && !isLoggingOut {
                markAsNeedingSave(change: .userPreferences)
            }
        }
    }

    @Published var selectedLocation: String? {
        didSet {
            if !isInitialLoad && !isLoggingOut {
                markAsNeedingSave(change: .userPreferences)
            }
        }
    }

    @Published var selectedDifficulty: String? {
        didSet {
            if !isInitialLoad && !isLoggingOut {
                markAsNeedingSave(change: .userPreferences)
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
        
        if currentUser != lastUser {
            print("👤 User change detected: '\(lastUser)' → '\(currentUser)'")
            // Clear any leftover data from previous user
            clearUserData()
            
            // Save current user as last active
            UserDefaults.standard.set(currentUser, forKey: "lastActiveUser")
        }
        print("OnboardingData at model init: \(onboardingData)")
        
        // Autofill preferences from onboarding data if not already set
        if selectedDifficulty == nil {
            print("difficulty: '\(onboardingData.trainingExperience.lowercased())'")
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
            subSkills: ["short_passing"],
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
            title: "Short Passing Drill Two",
            skill: "Passing",
            subSkills: ["short_passing"],
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
            title: "Short Passing Drill Three",
            skill: "Passing",
            subSkills: ["short_passing"],
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
            title: "Short Passing Four",
            skill: "Passing",
            subSkills: ["short_passing"],
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
            subSkills: ["long_passing"],
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
            subSkills: ["long_passing"],
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
            subSkills: ["power_shots"],
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
            subSkills: ["1v1_moves"],
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

    func loadInitialSession(from sessionResponse: SessionResponse) {

        print("\n🔄 Loading initial session with \(sessionResponse.drills.count) drills")
        
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
        
        // // Check if we have drills to process
        // guard !sessionResponse.drills.isEmpty else {
        //     print("⚠️ No drills found in the initial session response")
        //     addDefaultDrills()
        //     return
        // }
        
        // Convert API drills to app's drill models and add them to orderedDrills
        var processedCount = 0
        for apiDrill in sessionResponse.drills {
            do {
                let drillModel = apiDrill.toDrillModel()
                
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
        
        // // If no drills were loaded, add some default drills
        // if orderedSessionDrills.isEmpty {
        //     print("⚠️ No drills were loaded from the initial session, adding default drills")
        //     addDefaultDrills()
        // }
    }

    // Helper to map display skill names to backend keys, using - to separate category and subSkill
    func mapSelectedSkillsToBackend(_ displaySkills: Set<String>) -> Set<String> {
        let skillMap: [String: String] = [
            // Dribbling
            "Close control": "dribbling-close_control",
            "Speed dribbling": "dribbling-speed_dribbling",
            "1v1 moves": "dribbling-1v1_moves",
            "Change of direction": "dribbling-change_of_direction",
            "Ball mastery": "dribbling-ball_mastery",
            // First Touch
            "Ground control": "first_touch-ground_control",
            "Aerial control": "first_touch-aerial_control",
            "Turn with ball": "first_touch-turn_with_ball",
            "Touch and move": "first_touch-touch_and_move",
            "Juggling": "first_touch-juggling",
            // Passing
            "Short passing": "passing-short_passing",
            "Long passing": "passing-long_passing",
            "One touch passing": "passing-one_touch_passing",
            "Technique": "passing-technique",
            "Passing with movement": "passing-passing_with_movement",
            // Shooting
            "Power shots": "shooting-power_shots",
            "Finesse shots": "shooting-finesse_shots",
            "First time shots": "shooting-first_time_shots",
            "1v1 to shoot": "shooting-1v1_to_shoot",
            "Shooting on the run": "shooting-shooting_on_the_run",
            "Volleying": "shooting-volleying",
            // Defending (add if you have defending skills)
            "Tackling": "defending-tackling",
            "Marking": "defending-marking",
            "Intercepting": "defending-intercepting",
            "Positioning": "defending-positioning",
            // Add more as needed...
        ]
        return Set(displaySkills.compactMap { skillMap[$0] })
    }
    

    // Update the syncPreferencesWithBackend method
    func syncPreferencesWithBackend() async {
        // Convert display skill names to backend keys before sending
        let selectedSkillsSnakeCase = mapSelectedSkillsToBackend(selectedSkills)
        do {
            try await PreferencesUpdateService.shared.updatePreferences(
                time: selectedTime,
                equipment: selectedEquipment,
                trainingStyle: selectedTrainingStyle,
                location: selectedLocation,
                difficulty: selectedDifficulty,
                skills: selectedSkillsSnakeCase,
                sessionModel: self
            )
            print("✅ Successfully synced preferences with backend")
        } catch {
            print("❌ Failed to sync preferences with backend: \(error)")
        }
    }

}


