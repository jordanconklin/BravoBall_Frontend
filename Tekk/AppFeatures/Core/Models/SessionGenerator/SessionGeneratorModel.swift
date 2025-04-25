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
    
    
    var filterChangeTracker = FilterChangeTracker()
    
    @Published var selectedTime: String? {
        didSet {
            filterChangeTracker.selectedTimeChanged = true
            updateSessionByFilters(change: .selectedTimeChanged)
            markAsNeedingSave(change: .savedFilters)
        }
    }

    @Published var selectedEquipment: Set<String> = [] {
        didSet {
            filterChangeTracker.selectedEquipmentChanged = true
            updateSessionByFilters(change: .selectedEquipmentChanged)
            markAsNeedingSave(change: .savedFilters)
        }
    }

    @Published var selectedTrainingStyle: String? {
        didSet {
            filterChangeTracker.selectedTrainingStyleChanged = true
            updateSessionByFilters(change: .selectedTrainingStyleChanged)
            markAsNeedingSave(change: .savedFilters)
        }
    }

    @Published var selectedLocation: String? {
        didSet {
            filterChangeTracker.selectedLocationChanged = true
            updateSessionByFilters(change: .selectedLocationChanged)
            markAsNeedingSave(change: .savedFilters)
        }
    }

    @Published var selectedDifficulty: String? {
        didSet {
            filterChangeTracker.selectedDifficulty = true
            updateSessionByFilters(change: .selectedDifficulty)
            markAsNeedingSave(change: .savedFilters)
        }
    }

    // update by selected skills
    @Published var selectedSkills: Set<String> = [] {
        didSet {
            let availableDrills = getDrillsFromCache()
            
            // First filter by skills
            let skillFilteredDrills = !selectedSkills.isEmpty ? availableDrills.filter { drill in
                selectedSkills.contains { selectedSkill in
                    // Check if the drill's skill matches the selected skill
                    if drill.skill.lowercased() == selectedSkill.lowercased() {
                        return true
                    }
                    
                    // Check subskills
                    switch selectedSkill {
                    case /* Dribbling cases */
                        "Close control", "Speed dribbling", "1v1 moves", "Change of direction", "Ball mastery",
                        /* First Touch cases */
                        "Ground control", "Aerial control", "Turn with ball", "Touch and move", "Juggling",
                        /* Passing cases */
                        "Short passing", "Long passing", "One touch passing", "Technique", "Passing with movement",
                        /* Shooting cases */
                        "Power shots", "Finesse shots", "First time shots", "1v1 to shoot", "Shooting on the run", "Volleying":
                        
                        let searchTerm = selectedSkill.lowercased().replacingOccurrences(of: " ", with: "_")
                        return drill.subSkills.contains(where: { $0.contains(searchTerm) })
                        
                    default:
                        return false
                    }
                }
            } : availableDrills
            
            // Then apply any active filters
            let filteredByOtherCriteria = filterDrills(skillFilteredDrills, using: DrillFilters(
                time: nil, // Handle time separately
                equipment: selectedEquipment,
                trainingStyle: selectedTrainingStyle,
                location: selectedLocation,
                difficulty: selectedDifficulty
            ))
            
            // Finally, optimize for time if a time filter is active
            if let timeFilter = selectedTime {
                let targetMinutes = convertTimeFilterToMinutes(timeFilter)
                let timeOptimizedDrills = optimizeDrillsForTime(drills: filteredByOtherCriteria, targetMinutes: targetMinutes)
                updateOrderedSessionDrills(with: timeOptimizedDrills)
            } else {
                updateOrderedSessionDrills(with: filteredByOtherCriteria)
            }
            
            print("\n🎯 Skills Update Summary:")
            print("- Selected Skills: \(selectedSkills.joined(separator: ", "))")
            print("- After skill filtering: \(skillFilteredDrills.count) drills")
            print("- After other filters: \(filteredByOtherCriteria.count) drills")
            print("- Final session drills: \(orderedSessionDrills.count) drills")
            
            // Cache the changes
            markAsNeedingSave(change: .orderedDrills)
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
        
        
        // TODO: make recommended session instead of initializing filters w/ onboarding data
//        // Only set these values if they're not already loaded from cache
//        if selectedDifficulty == nil {
//            selectedDifficulty = onboardingData.trainingExperience.lowercased()
//        }
//        if selectedLocation == nil && !onboardingData.trainingLocation.isEmpty {
//            selectedLocation = onboardingData.trainingLocation.first
//        }
//        if selectedEquipment.isEmpty {
//            selectedEquipment = Set(onboardingData.availableEquipment)
//        }
//        if selectedTime == nil {
//            switch onboardingData.dailyTrainingTime {
//            case "Less than 15 minutes": selectedTime = "15min"
//            case "15-30 minutes": selectedTime = "30min"
//            case "30-60 minutes": selectedTime = "1h"
//            case "1-2 hours": selectedTime = "1h30"
//            case "More than 2 hours": selectedTime = "2h+"
//            default: selectedTime = "1h"
//            }
//        }
        
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

}


