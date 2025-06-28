//
//  CacheExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//
import Foundation
import SwiftKeychainWrapper

extension SessionGeneratorModel: CacheManagement {
    
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
    
   
    
    
    // MARK: - Cache Load Operations
//    func loadCachedData() {
//        isInitialLoad = true
//        
//        print("\n📱 Loading cached data for current user...")
//        let userEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? "no user"
//        print("\n👤 USER SESSION INFO:")
//        print("----------------------------------------")
//        print("Current user email: \(userEmail)")
//        
//        // If no user is logged in or changing users, ensure we don't load old data
//        if userEmail == "no user" {
//            print("⚠️ No valid user found, clearing any existing data")
//            clearUserData()
//            return
//        }
//        
//        // First load all cached data
//        loadAllFromCache()
//        
//        // Then sync with backend
//        Task {
//            await syncAllWithBackend()
//            // TODO: Load and cache database drills later on?
////            await loadAndCacheDatabaseDrills()
//            // set isInitialLoad to false after all data is loaded and synced with backend
//            await MainActor.run {
//                isInitialLoad = false
//            }
//        }
//    }
    
    func loadAllFromCache() {
        print("\n📱 Loading all data from cache...")
        
        // Load ordered drills
        if let cachedDrills: [EditableDrillModel] = cacheManager.retrieve(forKey: .orderedDrillsCase) {
            orderedSessionDrills = cachedDrills
            print("✅ Loaded \(orderedSessionDrills.count) ordered drills from cache")
            
            // Extract and update skills if needed
            if !cachedDrills.isEmpty {
                let drillSkills = Set(cachedDrills.map { $0.drill.skill })
                if selectedSkills.isEmpty {
                    selectedSkills = drillSkills
                    print("✅ Updated selected skills from cached drills: \(drillSkills)")
                }
            }
        }
        
        // Load completed sessions
        if let completedSessions: [CompletedSession] = cacheManager.retrieve(forKey: .allCompletedSessionsCase) {
            appModel.allCompletedSessions = completedSessions
            print("✅ Loaded \(completedSessions.count) completed sessions from cache")
        }
        
        // Load preferences
        if let preferences: Preferences = cacheManager.retrieve(forKey: .filterGroupsCase) {
            selectedTime = preferences.selectedTime
            selectedEquipment = Set(preferences.selectedEquipment)
            selectedTrainingStyle = preferences.selectedTrainingStyle
            selectedLocation = preferences.selectedLocation
            selectedDifficulty = preferences.selectedDifficulty
            print("✅ Loaded preferences from cache")
        }
        
        // Load filter groups
        if let filterGroups: [SavedFiltersModel] = cacheManager.retrieve(forKey: .filterGroupsCase) {
            allSavedFilters = filterGroups
            print("✅ Loaded \(filterGroups.count) filter groups from cache")
        }
        
        // Load saved drills and their backend IDs
        if let drills: [GroupModel] = cacheManager.retrieve(forKey: .savedDrillsCase) {
            savedDrills = drills
            print("✅ Loaded \(drills.count) saved drill groups from cache")
        }
        if let ids: [UUID: Int] = cacheManager.retrieve(forKey: .groupBackendIdsCase) {
            groupBackendIds = ids
            print("✅ Loaded \(ids.count) group backend IDs from cache")
        }
        
        // Load liked drills and their backend ID
        if let liked: GroupModel = cacheManager.retrieve(forKey: .likedDrillsCase) {
            likedDrillsGroup = liked
            print("✅ Loaded liked drills group from cache (\(liked.drills.count) drills)")
        }
        if let id: Int = cacheManager.retrieve(forKey: .likedGroupBackendIdCase) {
            likedGroupBackendId = id
            print("✅ Loaded liked group backend ID from cache")
        }
        
        // Load progress history
        if let currentStreak: Int = cacheManager.retrieve(forKey: .currentStreakCase) {
            appModel.currentStreak = currentStreak
            print("✅ Loaded current streak: \(currentStreak)")
        }
        if let highestStreak: Int = cacheManager.retrieve(forKey: .highestSreakCase) {
            appModel.highestStreak = highestStreak
            print("✅ Loaded highest streak: \(highestStreak)")
        }
        if let completedCount: Int = cacheManager.retrieve(forKey: .countOfCompletedSessionsCase) {
            appModel.countOfFullyCompletedSessions = completedCount
            print("✅ Loaded completed sessions count: \(completedCount)")
        }
    }
    
    
    // TODO: put this in syncing management for sesgenmodel extension
    private func syncAllWithBackend() async {
        print("\n🔄 Syncing all data with backend...")
        
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
//                // Sync ordered drills
//                group.addTask {
//                let backendDrills = try await DataSyncService.shared.fetchOrderedDrills()
//                    if backendDrills != self.orderedSessionDrills {
//                await MainActor.run {
//                            self.orderedSessionDrills = backendDrills
//                            self.cacheOrderedDrills()
//                            print("✅ Updated ordered drills from backend")
//                        }
//                    }
//                }
                
//                // Sync completed sessions
//                group.addTask {
//                    let backendSessions = try await DataSyncService.shared.fetchCompletedSessions()
//                    if backendSessions != self.appModel.allCompletedSessions {
//                await MainActor.run {
//                            self.appModel.allCompletedSessions = backendSessions
//                            self.appModel.cacheCompletedSessions()
//                            print("✅ Updated completed sessions from backend")
//                        }
//                    }
//                }
                
//                // Sync progress history
//                group.addTask {
//                    let progressHistory = try await DataSyncService.shared.fetchProgressHistory()
//                    await MainActor.run {
//                        if progressHistory.currentStreak != self.appModel.currentStreak {
//                            self.appModel.currentStreak = progressHistory.currentStreak
//                            self.appModel.cacheCurrentStreak()
//                        }
//                        if progressHistory.highestStreak != self.appModel.highestStreak {
//                            self.appModel.highestStreak = progressHistory.highestStreak
//                            self.appModel.cacheHighestStreak()
//                        }
//                        if progressHistory.completedSessionsCount != self.appModel.countOfFullyCompletedSessions {
//                            self.appModel.countOfFullyCompletedSessions = progressHistory.completedSessionsCount
//                            self.appModel.cacheCompletedSessionsCount()
//                        }
//                        print("✅ Updated progress history from backend")
//                    }
//                }
                
//                // Sync saved filters
//                group.addTask {
//                    let backendFilters = try await SavedFiltersService.shared.fetchSavedFilters()
//                    
//                    // Only update if there are actual differences
//                    let needsUpdate = backendFilters.count != self.allSavedFilters.count ||
//                        zip(backendFilters, self.allSavedFilters).contains { backend, local in
//                            backend.name != local.name ||
//                            backend.savedTime != local.savedTime ||
//                            backend.savedEquipment != local.savedEquipment ||
//                            backend.savedTrainingStyle != local.savedTrainingStyle ||
//                            backend.savedLocation != local.savedLocation ||
//                            backend.savedDifficulty != local.savedDifficulty
//                        }
//                    
//                    if needsUpdate {
//                        print("🔄 Filter differences detected, updating local cache...")
//                        await MainActor.run {
//                            self.allSavedFilters = backendFilters
//                            self.cacheFilterGroups(name: "")
//                            print("✅ Updated filter groups from backend")
//                        }
//                    } else {
//                        print("✓ Filters are in sync with backend")
//                    }
//                }
                
//                // Sync drill groups (both saved and liked)
//                group.addTask {
//                    // First check if we need to sync by comparing with cache
//                    let cachedGroups: [GroupModel] = self.savedDrills
//                    let cachedLikedGroup: GroupModel = self.likedDrillsGroup
//                    
//                    // Only sync if there are differences
//                    let needsSync = cachedGroups.count != self.savedDrills.count ||
//                        zip(cachedGroups, self.savedDrills).contains { cached, current in
//                            cached.drills.count != current.drills.count ||
//                            Set(cached.drills.map { $0.id }) != Set(current.drills.map { $0.id })
//                        } ||
//                        Set(cachedLikedGroup.drills.map { $0.id }) != Set(self.likedDrillsGroup.drills.map { $0.id })
//                    
//                    if needsSync {
//                        print("🔄 Drill group differences detected, syncing with backend...")
//                        try await self.loadDrillGroupsFromBackend()
//                        print("✅ Updated drill groups from backend")
//                    } else {
//                        print("✓ Drill groups are in sync with cache")
//                    }
//                }
//                
//                // Sync preferences
//                group.addTask {
//                    do {
//                        let preferences = try await PreferencesUpdateService.shared.fetchPreferences()
//                        await MainActor.run {
//                            // Convert duration to time string
//                            self.selectedTime = PreferencesUpdateService.shared.convertMinutesToTimeString(preferences.duration ?? 0)
//                            print("[DEBUG] selectedTime set to: \(self.selectedTime ?? "nil") from duration: \(preferences.duration?.description ?? "nil")")
//                            
//                            // Update equipment
//                            self.selectedEquipment = Set(preferences.availableEquipment ?? [])
//                            print("[DEBUG] selectedEquipment set to: \(self.selectedEquipment)")
//                            
//                            // Update other preferences
//                            self.selectedTrainingStyle = preferences.trainingStyle
//                            print("[DEBUG] selectedTrainingStyle set to: \(self.selectedTrainingStyle ?? "nil")")
//                            self.selectedLocation = preferences.trainingLocation
//                            print("[DEBUG] selectedLocation set to: \(self.selectedLocation ?? "nil")")
//                            self.selectedDifficulty = preferences.difficulty
//                            print("[DEBUG] selectedDifficulty set to: \(self.selectedDifficulty ?? "nil")")
//                            
//                            // Convert backend skills to frontend format
//                            self.selectedSkills = Set(preferences.targetSkills ?? [])
//                            print("[DEBUG] selectedSkills set to: \(self.selectedSkills)")
//                            
//                            // Cache the updated preferences
//                            self.cachePreferences()
//                            print("✅ Updated preferences from backend")
//                        }
//                    } catch {
//                        print("❌ Failed to sync preferences with backend: \(error)")
//                    }
//                }
                
                // Wait for all sync operations to complete
                try await group.waitForAll()
            }
            
            // After all syncs complete successfully
            await MainActor.run {
                isInitialLoad = false
                print("✅ Successfully synced all data with backend")
            }
            
        } catch {
            await MainActor.run {
                isInitialLoad = false
                print("⚠️ Error syncing with backend: \(error)")
                // Keep using cached data if backend sync fails
            }
        }
    }
    
   func cacheFilterGroups(name: String) {
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
    func cacheSavedDrills() {
        guard !isLoggingOut else {
            print("⚠️ Skipping saved drills cache during logout")
            return
        }
        cacheManager.cache(savedDrills, forKey: .savedDrillsCase)
        // Also cache the backend IDs
        cacheManager.cache(groupBackendIds, forKey: .groupBackendIdsCase)
    }
    
    // Updated method for caching liked drills
    func cacheLikedDrills() {
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
    
    
    // Fetch and set user data
    func loadBackendData() async {
        print("\n🚀 ===== STARTING loadBackendData() =====")
        print("📅 Timestamp: \(Date())")
        
        print("\n📱 Loading cached data for current user...")
        let userEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? "no user"
        print("\n👤 USER SESSION INFO:")
        print("----------------------------------------")
        print("Current user email: \(userEmail)")
        print("isInitialLoad: \(isInitialLoad)")
        print("isLoggingOut: \(isLoggingOut)")
        
        // If no user is logged in or changing users, ensure we don't load old data
        if userEmail == "no user" {
            print("⚠️ No valid user found, clearing any existing data")
            clearUserData()
            print("❌ loadBackendData() EXITING - No user found")
            return
        }
        
        print("✅ User validation passed")
        isInitialLoad = true
        self.appModel.isInitialLoad = true
        print("✅ Set isInitialLoad = true")
        
        print("\n🔄 Starting backend data fetch with task group...")
        
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                print("📦 Task group created successfully")
                
                // ordered drills
                print("\n📋 Adding ordered drills task...")
                group.addTask {
                    print("🔄 [TASK] Starting ordered drills fetch...")
                    let backendDrills = try await DataSyncService.shared.fetchOrderedDrills()
                    print("✅ [TASK] Successfully fetched \(backendDrills.count) ordered drills from backend")
                    
                    await MainActor.run {
                        print("🔄 [MAIN] Updating orderedSessionDrills on main thread...")
                        print("📊 [MAIN] Previous count: \(self.orderedSessionDrills.count)")
                        self.orderedSessionDrills = backendDrills
                        print("📊 [MAIN] New count: \(self.orderedSessionDrills.count)")
                        print("✅ [MAIN] orderedSessionDrills updated successfully")
                    }
                }
                
                // completed sessions

                group.addTask {

                    let backendSessions = try await DataSyncService.shared.fetchCompletedSessions()

                    
                    await MainActor.run {
                        
                        self.appModel.allCompletedSessions = backendSessions
                        
                        print("count in array: \(self.appModel.allCompletedSessions.count)")
                    }
                }
                

                
                // progress history
                group.addTask {

                    let progressHistory = try await DataSyncService.shared.fetchProgressHistory()
                    
                    await MainActor.run {

                        
                        self.appModel.currentStreak = progressHistory.currentStreak
                        self.appModel.highestStreak = progressHistory.highestStreak
                        self.appModel.countOfFullyCompletedSessions = progressHistory.completedSessionsCount
                        
                        print("✅ [MAIN] Progress history updated successfully")
                    }
                }
                
                // saved filters
                print("\n📋 Adding saved filters task...")
                group.addTask {
                    print("🔄 [TASK] Starting saved filters fetch...")
                    let backendFilters = try await SavedFiltersService.shared.fetchSavedFilters()
                    print("✅ [TASK] Successfully fetched \(backendFilters.count) saved filters from backend")
                    
                    await MainActor.run {
                        print("🔄 [MAIN] Updating allSavedFilters on main thread...")
                        print("📊 [MAIN] Previous count: \(self.allSavedFilters.count)")
                        self.allSavedFilters = backendFilters
                        print("📊 [MAIN] New count: \(self.allSavedFilters.count)")
                        print("✅ [MAIN] allSavedFilters updated successfully")
                    }
                }
                
                // drill groups
                print("\n📋 Adding drill groups task...")
                group.addTask {
                    print("🔄 [TASK] Starting drill groups fetch...")
                    print("⚠️ [TASK] Note: loadDrillGroupsFromBackend() updates UI directly (not in MainActor)")
                    
                    try await self.loadDrillGroupsFromBackend()
                    
                    print("✅ [TASK] Drill groups loaded successfully")
                    print("📊 [TASK] Final counts:")
                    print("   - Saved drills: \(self.savedDrills.count)")
                    print("   - Liked drills: \(self.likedDrillsGroup.drills.count)")
                    print("   - Group backend IDs: \(self.groupBackendIds.count)")
                }
                
                // preferences
                print("\n📋 Adding preferences task...")
                group.addTask {
                    print("🔄 [TASK] Starting preferences fetch...")
                    let preferences = try await PreferencesUpdateService.shared.fetchPreferences()
                    print("✅ [TASK] Successfully fetched preferences from backend")
                    print("📊 [TASK] Preferences data:")
                    print("   - Duration: \(preferences.duration ?? 0)")
                    print("   - Equipment: \(preferences.availableEquipment ?? [])")
                    print("   - Training style: \(preferences.trainingStyle ?? "nil")")
                    print("   - Location: \(preferences.trainingLocation ?? "nil")")
                    print("   - Difficulty: \(preferences.difficulty ?? "nil")")
                    print("   - Target skills: \(preferences.targetSkills ?? [])")
                    
                    await MainActor.run {
                        print("🔄 [MAIN] Updating preferences on main thread...")
                        
                        // Convert duration to time string
                        self.selectedTime = PreferencesUpdateService.shared.convertMinutesToTimeString(preferences.duration ?? 0)
                        print("📊 [MAIN] selectedTime: \(self.selectedTime ?? "nil")")
                        
                        // Update equipment
                        self.selectedEquipment = Set(preferences.availableEquipment ?? [])
                        print("📊 [MAIN] selectedEquipment: \(self.selectedEquipment)")
                        
                        // Update other preferences
                        self.selectedTrainingStyle = preferences.trainingStyle
                        print("📊 [MAIN] selectedTrainingStyle: \(self.selectedTrainingStyle ?? "nil")")

                        self.selectedLocation = preferences.trainingLocation
                        print("📊 [MAIN] selectedLocation: \(self.selectedLocation ?? "nil")")

                        self.selectedDifficulty = preferences.difficulty
                        print("📊 [MAIN] selectedDifficulty: \(self.selectedDifficulty ?? "nil")")
                        
                        // Convert backend skills to frontend format
                        self.selectedSkills = Set(preferences.targetSkills ?? [])
                        print("📊 [MAIN] selectedSkills: \(self.selectedSkills)")
                        
                        print("✅ [MAIN] All preferences updated successfully")
                    }
                }
                
                print("\n⏳ Waiting for all remaining tasks to complete...")
                try await group.waitForAll()
                print("✅ All tasks completed successfully")
                isInitialLoad = false
                self.appModel.isInitialLoad = false
                print("✅ Set isInitialLoad = false")
            }
            
            print("\n🎉 ===== loadBackendData() COMPLETED SUCCESSFULLY =====")
            print("📊 Final data summary:")
            print("   - Ordered drills: \(orderedSessionDrills.count)")
            print("   - Completed sessions: \(appModel.allCompletedSessions.count)")
            print("   - Current streak: \(appModel.currentStreak)")
            print("   - Saved filters: \(allSavedFilters.count)")
            print("   - Saved drill groups: \(savedDrills.count)")
            print("   - Liked drills: \(likedDrillsGroup.drills.count)")
            print("   - Selected skills: \(selectedSkills)")
            
            } catch {
            print("\n❌ ===== loadBackendData() FAILED =====")
            print("Error fetching user's data: \(error)")
                    print("Error type: \(type(of: error))")
                    print("Error description: \(error.localizedDescription)")
            
            if let decodingError = error as? DecodingError {
                print("🔍 Decoding error details:")
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("   - Missing key: \(key)")
                    print("   - Context: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("   - Type mismatch: expected \(type)")
                    print("   - Context: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("   - Value not found for type: \(type)")
                    print("   - Context: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("   - Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("   - Unknown decoding error")
        }
    }
}
        
        print("\n🏁 ===== loadBackendData() ENDED =====")
    }
}

