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
    


    
    // Fetch and set user data
    func loadBackendData(appModel: MainAppModel) async {
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
        appModel.isInitialLoad = true
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
                        
                        appModel.allCompletedSessions = backendSessions
                        
                    }
                }
                

                
                // progress history
                group.addTask {

                    let progressHistory = try await DataSyncService.shared.fetchProgressHistory()
                    
                    await MainActor.run {

                        
                        appModel.currentStreak = progressHistory.currentStreak
                        appModel.highestStreak = progressHistory.highestStreak
                        appModel.countOfFullyCompletedSessions = progressHistory.completedSessionsCount
                        
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
                appModel.isInitialLoad = false
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

