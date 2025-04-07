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
}
