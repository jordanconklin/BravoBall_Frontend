
//
//  SavedDrillsExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//
import Foundation

extension SessionGeneratorModel: SavedDrillsGroupManagement {
    
    func isDrillInGroup(_ drill: DrillModel) -> Bool {
        for group in savedDrills {
            if group.drills.contains(drill) {
                return true
            }
        }
        return false
    }
    
    func addDrillToGroup(drill: DrillModel, groupId: UUID) {
        if let index = savedDrills.firstIndex(where: { $0.id == groupId }) {
            // Add drill to local sessionGeneratorModel
            if !savedDrills[index].drills.contains(drill) {
                savedDrills[index].drills.append(drill)
            }
            
            // Add to backend if we have a backend ID
            if let backendId = groupBackendIds[groupId] {
                Task {
                    do {
                        if let drillBackendId = drill.backendId {
                            _ = try await DrillGroupService.shared.addDrillToGroup(groupId: backendId, drillId: drillBackendId)
                            print("✅ Successfully added drill to group on backend")
                        } else {
                            print("⚠️ No backend ID available for drill: \(drill.title)")
                        }
                    } catch {
                        print("❌ Error adding drill to group on backend: \(error)")
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
        
        // Add to local sessionGeneratorModel
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
        // Remove from local sessionGeneratorModel
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
    
    // Updated method to remove drill from group
    func removeDrillFromGroup(drill: DrillModel, groupId: UUID) {
        
        if let index = savedDrills.firstIndex(where: { $0.id == groupId }) {
            // Remove drill from local sessionGeneratorModel
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
        }
    }
}
