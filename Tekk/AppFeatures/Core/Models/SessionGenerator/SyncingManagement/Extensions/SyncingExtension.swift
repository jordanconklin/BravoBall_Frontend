//
//  SyncingExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//
import Foundation

extension SessionGeneratorModel: SyncManagement {
    
    //TODO: get rid of useless stuff here
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
}
