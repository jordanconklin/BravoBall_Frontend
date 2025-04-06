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
    
    
    
    private let cacheManager = CacheManager.shared
    private var lastSyncTime: Date = Date()
    private let syncDebounceInterval: TimeInterval = 2.0 // 2 seconds
    private var hasUnsavedChanges = false
    private var autoSaveTimer: Timer?
    private var isLoggingOut = false  // Add flag to prevent caching during logout
    
    // FilterTypes
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
    @Published var selectedDrills: [DrillModel] = []
    @Published var selectedDrillForEditing: EditableDrillModel?
    @Published var recommendedDrills: [DrillModel] = []
    
    
    
    // MARK: Cached Data
    // SessionGenerator Drills storage
    @Published var orderedSessionDrills: [EditableDrillModel] = [] {
        didSet { 
            markAsNeedingSave(change: .orderedDrills)
        }
    }
    // Saved Drills storage
    @Published var savedDrills: [GroupModel] = [] {
        didSet { 
            markAsNeedingSave(change: .savedDrills)
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
            markAsNeedingSave(change: .savedFilters)
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
        
        // Initialize liked drills group with user-specific UUID
        likedDrillsGroup = GroupModel(
            id: getLikedDrillsUUID(),
            name: "Liked Drills",
            description: "Your favorite drills",
            drills: []
        )
        
        loadCachedData()
        // Force deduplication on app launch
        deduplicateAllGroups()
        
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
                
        
        // After loading from cache, try to refresh from backend
        Task {
            await loadDrillGroupsFromBackend()
        }
        
        // Load saved filters data from backend
        Task {
            await loadSavedFiltersFromBackend()
        }
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
    
    
    
    // MARK: Syncing
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


    
    // MARK: - Group Management Methods
    
    // Add a property to track backend IDs for each group
    var groupBackendIds: [UUID: Int] = [:]
    
    // Add a property to track the backend ID for the liked group
    var likedGroupBackendId: Int?
    

    
    // Updated method to remove drill from group
    func removeDrillFromGroup(drill: DrillModel, groupId: UUID) {
        if let index = savedDrills.firstIndex(where: { $0.id == groupId }) {
            // Remove drill from local model
            savedDrills[index].drills.removeAll(where: { $0.id == drill.id })
            
            // Remove from backend if we have a backend ID
            if let backendId = groupBackendIds[groupId] {
                Task {
                    do {
                        if let drillBackendId = drill.backendId {
                            _ = try await DrillGroupService.shared.removeDrillFromGroup(groupId: backendId, drillId: drillBackendId)
                            print("✅ Successfully removed drill from group on backend")
                        } else {
                            print("⚠️ No backend ID available for drill: \(drill.title)")
                        }
                    } catch {
                        print("❌ Error removing drill from group on backend: \(error)")
                    }
                }
            }
        }
    }
    
    // Updated method to create a group
    func createGroup(name: String, description: String) {
        let groupModel = GroupModel(
            name: name,
            description: description,
            drills: []
        )
        
        // Add to local model
        savedDrills.append(groupModel)
        
        // Create on backend
        Task {
            do {
                let response = try await DrillGroupService.shared.createDrillGroupWithIds(
                    name: name, 
                    description: description,
                    drillIds: [], // Empty array for new group
                    isLikedGroup: false
                )
                // Store the backend ID
                groupBackendIds[groupModel.id] = response.id
                print("✅ Successfully created group on backend with ID: \(response.id)")
            } catch {
                print("❌ Error creating group on backend: \(error)")
            }
        }
    }
    
    // Add a method to delete a group
    func deleteGroup(groupId: UUID) {
        // Remove from local model
        savedDrills.removeAll(where: { $0.id == groupId })
        
        // Delete from backend if we have a backend ID
        if let backendId = groupBackendIds[groupId] {
            Task {
                do {
                    _ = try await DrillGroupService.shared.deleteDrillGroup(groupId: backendId)
                    // Remove the stored backend ID
                    groupBackendIds.removeValue(forKey: groupId)
                    print("✅ Successfully deleted group from backend")
                } catch {
                    print("❌ Error deleting group from backend: \(error)")
                }
            }
        }
    }


    


    
    // Filter value that is selected, or if its empty
    func filterValue(for type: FilterType) -> String {
        let value = switch type {
        case .time:
            selectedTime ?? ""
        case .equipment:
            selectedEquipment.isEmpty ? "" : "\(selectedEquipment.count) selected"
        case .trainingStyle:
            selectedTrainingStyle ?? ""
        case .location:
            selectedLocation ?? ""
        case .difficulty:
            selectedDifficulty ?? ""
        }
        
        return value
    }
    
    // Save filters into saved filters group
    func saveFiltersInGroup(name: String) {
        
        guard !name.isEmpty else { return }
        
        let savedFilters = SavedFiltersModel(
            name: name,
            savedTime: selectedTime,
            savedEquipment: selectedEquipment,
            savedTrainingStyle: selectedTrainingStyle,
            savedLocation: selectedLocation,
            savedDifficulty: selectedDifficulty
        )
        
        allSavedFilters.append(savedFilters)
        
        cacheFilterGroups(name: name)
    }
    
    // Load filter after clicking the name of saved filter
    func loadFilter(_ filter: SavedFiltersModel) {
        selectedTime = filter.savedTime
        selectedEquipment = filter.savedEquipment
        selectedTrainingStyle = filter.savedTrainingStyle
        selectedLocation = filter.savedLocation
        selectedDifficulty = filter.savedDifficulty
    }
    
    
    
    
    
    
    
    
    // MARK: - Cache Operations
    
    // Clear all user data when logging out
    func clearUserData() {
        print("\n🧹 Clearing user data...")
        
        // Cancel any pending auto-save timer
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
        
        // Reset change tracker
        changeTracker = DataChangeTracker()
        hasUnsavedChanges = false
        
        // First clear all published properties
        orderedSessionDrills = []
        savedDrills = []
        likedDrillsGroup = GroupModel(
            id: getLikedDrillsUUID(), // Use user-specific UUID
            name: "Liked Drills",
            description: "Your favorite drills",
            drills: []
        )
        groupBackendIds = [:]
        likedGroupBackendId = nil
        selectedDrills = []
        allSavedFilters = []
        
        // Clear filter preferences
        selectedTime = nil
        selectedEquipment = []
        selectedTrainingStyle = nil
        selectedLocation = nil
        selectedDifficulty = nil
        selectedSkills = []
        
        // Clear user cache to ensure data doesn't persist for new users
        CacheManager.shared.clearUserCache()
        
        print("✅ User data and cache cleared successfully")
    }
    
    
    // Displaying cached data for specific user based off email in keychain
    func loadCachedData() {
        print("\n📱 Loading cached data for current user...")
        let userEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? "no user"
        print("\n👤 USER SESSION INFO:")
        print("----------------------------------------")
        print("Current user email: \(userEmail)")
        print("Cache key being used: \(CacheKey.orderedDrillsCase.forUser(userEmail))")
        print("----------------------------------------")
        
        // If no user is logged in or changing users, ensure we don't load old data
        if userEmail == "no user" {
            print("⚠️ No valid user found, clearing any existing data")
            clearUserData()
            return
        }
        
        // Load preferences
        if let preferences: Preferences = cacheManager.retrieve(forKey: .filterGroupsCase) {
            selectedTime = preferences.selectedTime
            selectedEquipment = Set(preferences.selectedEquipment)
            selectedTrainingStyle = preferences.selectedTrainingStyle
            selectedLocation = preferences.selectedLocation
            selectedDifficulty = preferences.selectedDifficulty
            print("✅ Successfully loaded preferences from cache")
        }
        
        // Load ordered drills
        if let drills: [EditableDrillModel] = cacheManager.retrieve(forKey: .orderedDrillsCase) {
            print("\n📋 ORDERED DRILLS FOR USER \(userEmail):")
            print("----------------------------------------")
            print("Number of drills found: \(drills.count)")
            print("Drill titles:")
            drills.enumerated().forEach { index, drill in
                print("  \(index + 1). \(drill.drill.title) (Completed: \(drill.isCompleted))")
            }
            print("----------------------------------------")
            orderedSessionDrills = drills
            
            // Ensure we don't override these drills with default ones
            if !drills.isEmpty {
                print("✅ Using cached drills instead of default drills")
                
                // Extract skills from the loaded drills
                let drillSkills = Set(drills.map { $0.drill.skill })
                print("📊 Skills from cached drills: \(drillSkills)")
                
                // Update selected skills based on the loaded drills
                if selectedSkills.isEmpty {
                    selectedSkills = drillSkills
                    print("✅ Updated selected skills from cached drills: \(selectedSkills)")
                }
            }
        } else {
            print("\n📋 ORDERED DRILLS FOR USER \(userEmail):")
            print("----------------------------------------")
            print("ℹ️No drills found in cache")
            print("----------------------------------------")
        }
        
        // Load filter groups
        if let filterGroups: [SavedFiltersModel] = cacheManager.retrieve(forKey: .filterGroupsCase) {
            allSavedFilters = filterGroups
            print("✅ Successfully loaded filter groups from cache")
            print("Number of filter groups: \(filterGroups.count)")
        } else {
            print("ℹ️ No filter groups found in cache")
        }
        
        // Load saved drills
        if let drills: [GroupModel] = cacheManager.retrieve(forKey: .savedDrillsCase) {
            savedDrills = drills
            print("✅ Successfully loaded saved drills from cache")
        } else {
            print("ℹ️ No saved drills found in cache")
        }
        
        // Load backend IDs for groups
        if let ids: [UUID: Int] = cacheManager.retrieve(forKey: .groupBackendIdsCase) {
            groupBackendIds = ids
            print("✅ Successfully loaded group backend IDs from cache")
        }
        
        // Load liked drills
        if let liked: GroupModel = cacheManager.retrieve(forKey: .likedDrillsCase) {
            likedDrillsGroup = liked
            print("✅ Successfully loaded liked drills from cache")
        } else {
            print("ℹ️ No liked drills found in cache")
        }
        
        // Load backend ID for liked group
        if let id: Int = cacheManager.retrieve(forKey: .likedGroupBackendIdCase) {
            likedGroupBackendId = id
            print("✅ Successfully loaded liked group backend ID from cache")
        }
        
        // After loading from cache, try to refresh from backend
        Task {
            await loadDrillGroupsFromBackend()
        }
    }
    
    private func cacheFilterGroups(name: String) {
        guard !isLoggingOut else { 
            print("⚠️ Skipping filter groups cache during logout")
            return 
        }
        // No need to create new preferences or append again since it's already done in saveFiltersInGroup
        cacheManager.cache(allSavedFilters, forKey: .filterGroupsCase)
        print("💾 Saved \(allSavedFilters.count) filter groups to cache")
    }
    
    func cacheOrderedDrills() {
        guard !isLoggingOut else { 
            print("⚠️ Skipping ordered drills cache during logout")
            return 
        }
        print("\n💾 Saving ordered drills to cache...")
        print("Number of drills to save: \(orderedSessionDrills.count)")
        cacheManager.cache(orderedSessionDrills, forKey: .orderedDrillsCase)
    }
    
    // Updated method for caching saved drills
    private func cacheSavedDrills() {
        guard !isLoggingOut else { 
            print("⚠️ Skipping saved drills cache during logout")
            return 
        }
        cacheManager.cache(savedDrills, forKey: .savedDrillsCase)
        // Also cache the backend IDs
        cacheManager.cache(groupBackendIds, forKey: .groupBackendIdsCase)
    }
    
    // Updated method for caching liked drills
    private func cacheLikedDrills() {
        guard !isLoggingOut else { 
            print("⚠️ Skipping liked drills cache during logout")
            return 
        }
        cacheManager.cache(likedDrillsGroup, forKey: .likedDrillsCase)
        // Also cache the backend ID
        if let likedGroupBackendId = likedGroupBackendId {
            cacheManager.cache(likedGroupBackendId, forKey: .likedGroupBackendIdCase)
        }
    }
    
    
    
    
    
    
    
    
    // MARK: - Loading and Syncing with Backend
    

    
    // Update the addDrillsToGroup method to use the unified approach from DrillGroupService
    func addDrillsToGroup(drills: [DrillModel], groupId: UUID? = nil, isLikedGroup: Bool = false) -> Int {
        print("\n🔍 DEBUG - addDrillsToGroup in SessionGeneratorModel:")
        print("  - isLikedGroup: \(isLikedGroup)")
        
        var actuallyAddedCount = 0
        
        // Check if the provided groupId matches the likedDrillsGroup's id
        if let groupId = groupId, groupId == likedDrillsGroup.id {
            print("  - Detected request to add drills to the liked group via UUID: \(groupId)")
            print("  - likedDrillsGroup.id: \(likedDrillsGroup.id)")
            // Redirect to the liked group path
            return addDrillsToGroup(drills: drills, isLikedGroup: true)
        }
        
        if isLikedGroup {
            // Handle liked drills group
            print("  - Adding \(drills.count) drills to liked group (id: \(likedDrillsGroup.id))")
            
            // Add each drill to the group if it's not already there
            for drill in drills {
                if !likedDrillsGroup.drills.contains(where: { $0.id == drill.id }) && 
                   !likedDrillsGroup.drills.contains(where: { $0.title == drill.title }) {
                    likedDrillsGroup.drills.append(drill)
                    actuallyAddedCount += 1
                    print("  - Added drill: '\(drill.title)'")
                } else {
                    print("  - Skipped drill (already exists): '\(drill.title)'")
                }
            }
            
            print("✅ Added \(actuallyAddedCount) new drills to liked group locally")
            
            // Deduplicate liked drills group to ensure no duplicates
            deduplicateLikedDrills()
            
            // Notify UI of the update
            print("📣 Posting LikedDrillsUpdated notification")
            NotificationCenter.default.post(
                name: Notification.Name("LikedDrillsUpdated"),
                object: nil,
                userInfo: ["likedGroupId": likedDrillsGroup.id]
            )
        } else {
            // Handle regular drill group
            guard let groupId = groupId else {
                print("❌ ERROR: No group ID provided for regular drill group")
                return 0
            }
            
            print("  - Local Group ID (UUID): \(groupId)")
            print("  - Adding \(drills.count) drills")
            
            // Find the group in the saved drills
            if let groupIndex = savedDrills.firstIndex(where: { $0.id == groupId }) {
                print("✅ Found group at index \(groupIndex): '\(savedDrills[groupIndex].name)'")
                
                // Add each drill to the group if it's not already there
                for drill in drills {
                    if !savedDrills[groupIndex].drills.contains(where: { $0.id == drill.id }) && 
                       !savedDrills[groupIndex].drills.contains(where: { $0.title == drill.title }) {
                        savedDrills[groupIndex].drills.append(drill)
                        actuallyAddedCount += 1
                        print("  - Added drill: '\(drill.title)'")
                    } else {
                        print("  - Skipped drill (already exists): '\(drill.title)'")
                    }
                }
                
                print("✅ Added \(actuallyAddedCount) new drills to group locally")
                
                // Deduplicate the group to ensure no duplicates
                deduplicateDrills(in: groupIndex)
                
                // Notify UI of the update with the group ID
                NotificationCenter.default.post(
                    name: Notification.Name("DrillGroupUpdated"),
                    object: nil,
                    userInfo: ["groupId": groupId]
                )
            } else {
                print("❌ ERROR: Could not find group with ID \(groupId)")
                print("  - Available group IDs: \(savedDrills.map { $0.id })")
                print("  - Liked drills group ID: \(likedDrillsGroup.id)")
                return 0
            }
        }
        
        // Sync with backend using the unified approach
        Task {
            do {
                // Get backend IDs for all drills being added
                let drillBackendIds = drills.compactMap { $0.backendId }
                print("🔍 Drill backend IDs: \(drillBackendIds)")
                print("  - Found backend IDs for \(drillBackendIds.count) out of \(drills.count) drills")
                
                // Only proceed if we have valid backend IDs
                if drillBackendIds.isEmpty {
                    print("⚠️ No valid backend IDs found for drills")
                    return
                }
                
                // Get the backend group ID if needed
                var backendGroupId: Int? = nil
                if !isLikedGroup {
                    guard let groupId = groupId, let id = groupBackendIds[groupId] else {
                        print("⚠️ No backend ID found for group")
                        return
                    }
                    backendGroupId = id
                    print("✅ Found backend ID for group: \(backendGroupId!)")
                }
                
                // Use the unified method from DrillGroupService
                print("🔄 Calling DrillGroupService.addMultipleDrillsToAnyGroup...")
                let result = try await DrillGroupService.shared.addMultipleDrillsToAnyGroup(
                    groupId: backendGroupId,
                    drillIds: drillBackendIds,
                    isLikedGroup: isLikedGroup
                )
                
                print("✅ Successfully synced drills: \(result)")
                
                // Notify UI again after successful backend sync
                DispatchQueue.main.async {
                    if isLikedGroup {
                        NotificationCenter.default.post(
                            name: Notification.Name("LikedDrillsUpdated"),
                            object: nil,
                            userInfo: ["syncSuccess": true]
                        )
                    } else if let groupId = groupId {
                        NotificationCenter.default.post(
                            name: Notification.Name("DrillGroupUpdated"),
                            object: nil,
                            userInfo: ["groupId": groupId, "syncSuccess": true]
                        )
                    }
                }
            } catch {
                print("❌ Failed to sync drills: \(error)")
                
                // Notify UI of failure
                DispatchQueue.main.async {
                    let notificationName = isLikedGroup ? 
                        Notification.Name("LikedDrillsUpdated") : 
                        Notification.Name("DrillGroupUpdated")
                    
                    var userInfo: [String: Any] = ["syncError": error.localizedDescription]
                    if let groupId = groupId {
                        userInfo["groupId"] = groupId
                    }
                    
                    NotificationCenter.default.post(
                        name: notificationName,
                        object: nil,
                        userInfo: userInfo
                    )
                }
            }
        }
        
        return actuallyAddedCount
    }
    
    // For backward compatibility - this method is maintained for existing code that calls it directly
    // but it now uses the unified approach internally
    func addDrillsToLikedGroup(drills: [DrillModel]) -> Int {
        // Call the combined method with the isLikedGroup flag set to true
        return addDrillsToGroup(drills: drills, isLikedGroup: true)
    }
    
    // Remove duplicate drills from a group
    func deduplicateDrills(in groupIndex: Int) {
        // Create a Set to track seen drill IDs and titles
        var seenDrillIds = Set<UUID>()
        var seenDrillTitles = Set<String>()
        var uniqueDrills = [DrillModel]()
        
        for drill in savedDrills[groupIndex].drills {
            // Check for ID-based duplicates first
            if seenDrillIds.contains(drill.id) {
                print("🔄 Removing duplicate drill (ID match): '\(drill.title)' from group '\(savedDrills[groupIndex].name)'")
                continue
            }
            
            // Then check for title-based duplicates (same content with different IDs)
            if seenDrillTitles.contains(drill.title) {
                print("🔄 Removing duplicate drill (title match): '\(drill.title)' from group '\(savedDrills[groupIndex].name)'")
                continue
            }
            
            // This drill is unique, add it to our tracking and result list
            seenDrillIds.insert(drill.id)
            seenDrillTitles.insert(drill.title)
            uniqueDrills.append(drill)
        }
        
        // Update the group with unique drills
        if uniqueDrills.count != savedDrills[groupIndex].drills.count {
            print("🔄 Deduplicated \(savedDrills[groupIndex].drills.count - uniqueDrills.count) drills from group '\(savedDrills[groupIndex].name)'")
            savedDrills[groupIndex].drills = uniqueDrills
            // Make sure to cache the updated group
            cacheSavedDrills()
        }
    }
    
    // Remove duplicates from liked drills group
    func deduplicateLikedDrills() {
        // Create a Set to track seen drill IDs and titles
        var seenDrillIds = Set<UUID>()
        var seenDrillTitles = Set<String>()
        var uniqueDrills = [DrillModel]()
        
        for drill in likedDrillsGroup.drills {
            // Check for ID-based duplicates first
            if seenDrillIds.contains(drill.id) {
                print("🔄 Removing duplicate drill (ID match): '\(drill.title)' from liked drills group")
                continue
            }
            
            // Then check for title-based duplicates (same content with different IDs)
            if seenDrillTitles.contains(drill.title) {
                print("🔄 Removing duplicate drill (title match): '\(drill.title)' from liked drills group")
                continue
            }
            
            // This drill is unique, add it to our tracking and result list
            seenDrillIds.insert(drill.id)
            seenDrillTitles.insert(drill.title)
            uniqueDrills.append(drill)
        }
        
        // Update the liked drills group with unique drills
        if uniqueDrills.count != likedDrillsGroup.drills.count {
            print("🔄 Deduplicated \(likedDrillsGroup.drills.count - uniqueDrills.count) drills from liked drills group")
            likedDrillsGroup.drills = uniqueDrills
            // Make sure to cache the updated group
            cacheLikedDrills()
        }
    }
    
    // Deduplicate all groups
    func deduplicateAllGroups() {
        print("\n🔄 Running comprehensive deduplication on all drill groups...")
        
        // Deduplicate liked drills group
        deduplicateLikedDrills()
        
        // Deduplicate all saved groups
        for i in 0..<savedDrills.count {
            deduplicateDrills(in: i)
        }
        
        // Cache is updated directly in the individual deduplication methods
        print("✅ All groups deduplicated successfully")
    }
    
    // Load saved data from cache
    func loadSavedData() {
        if let savedDrills = CacheManager.shared.retrieve(forKey: .savedDrillsCase) as [GroupModel]? {
            self.savedDrills = savedDrills
            print("📋 Loaded \(savedDrills.count) saved drill groups")
        }
        
        if let likedDrills = CacheManager.shared.retrieve(forKey: .likedDrillsCase) as GroupModel? {
            self.likedDrillsGroup = likedDrills
            print("📋 Loaded \(likedDrills.drills.count) liked drills")
        }
        
        if let groupBackendIds = CacheManager.shared.retrieve(forKey: .groupBackendIdsCase) as [UUID: Int]? {
            self.groupBackendIds = groupBackendIds
            print("📋 Loaded \(groupBackendIds.count) group backend IDs")
        }
        
        if let likedGroupBackendId = CacheManager.shared.retrieve(forKey: .likedGroupBackendIdCase) as Int? {
            self.likedGroupBackendId = likedGroupBackendId
            print("📋 Loaded liked group backend ID: \(likedGroupBackendId)")
        }
        
        // Deduplicate all drill groups to ensure no duplicates
        deduplicateAllGroups()
    }
    
    // Get or create a user-specific UUID for the liked drills group
    private func getLikedDrillsUUID() -> UUID {
        let userEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? "default"
        let key = "\(userEmail)_likedDrillsUUID"
        
        // Check if we already have a UUID stored for this user
        if let uuidString = UserDefaults.standard.string(forKey: key), 
           let uuid = UUID(uuidString: uuidString) {
            print("📱 Using existing liked drills UUID for user: \(userEmail)")
            return uuid
        }
        
        // Generate a new UUID for this user
        let newUUID = UUID()
        UserDefaults.standard.set(newUUID.uuidString, forKey: key)
        print("📱 Generated new liked drills UUID for user: \(userEmail)")
        return newUUID
    }
    
    // Clear method to remove a user's likedDrillsUUID
    func clearLikedDrillsUUID() {
        let userEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? "default"
        let key = "\(userEmail)_likedDrillsUUID"
        UserDefaults.standard.removeObject(forKey: key)
        print("🗑️ Cleared liked drills UUID for user: \(userEmail)")
    }
    
    
    // Define Preferences struct for caching
    private struct Preferences: Codable {
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
    
    // MARK: - Backend Data Loading
    
    private func loadSavedFiltersFromBackend() async {
        do {
            let filters = try await SavedFiltersService.shared.fetchSavedFilters()
            await MainActor.run {
                self.allSavedFilters = filters
                print("✅ Successfully loaded \(filters.count) saved filters from backend")
                // Cache the updated filters
                cacheFilterGroups(name: "")
            }
        } catch {
            print("❌ Error loading saved filters from backend: \(error)")
            // Keep using cached data if backend fetch fails
        }
    }
}


