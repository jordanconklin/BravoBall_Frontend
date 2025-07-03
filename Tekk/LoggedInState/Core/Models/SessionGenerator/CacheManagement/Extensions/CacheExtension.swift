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
    
}

