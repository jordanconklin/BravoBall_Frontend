//
//  DrillGroupMgmtExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//


import Foundation

// MARK: - DrillGroupManagement Extension
extension SessionGeneratorModel: DrillGroupManagement {
    
    // MARK: - Group Management Methods
    func addDrillToGroup(drill: DrillModel, groupId: UUID) {
        if let index = savedDrills.firstIndex(where: { $0.id == groupId }) {
            // Add drill to local model
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
    
    func toggleDrillLike(drillId: UUID, drill: DrillModel) {
        if likedDrillsGroup.drills.contains(drill) {
            likedDrillsGroup.drills.removeAll(where: { $0.id == drillId })
        } else {
            likedDrillsGroup.drills.append(drill)
        }
        
        // Toggle on backend
        Task {
            do {
                if let backendDrillId = drill.backendId {
                    let response = try await DrillGroupService.shared.toggleDrillLike(drillId: backendDrillId)
                    print("✅ Successfully toggled drill like on backend: \(response.message)")
                } else {
                    print("⚠️ No backend ID available for drill: \(drill.title)")
                }
            } catch {
                print("❌ Error toggling drill like on backend: \(error)")
            }
        }
    }
    
    func isDrillLiked(_ drill: DrillModel) -> Bool {
        return likedDrillsGroup.drills.contains(drill)
    }
    
    func checkDrillLikedStatus(drillId: Int) async -> Bool {
        do {
            return try await DrillGroupService.shared.checkDrillLiked(drillId: drillId)
        } catch {
            print("❌ Error checking drill liked status: \(error)")
            // Fall back to local state, using backendId if available
            return likedDrillsGroup.drills.contains(where: { $0.backendId == drillId })
        }
    }
    
    func loadDrillGroupsFromBackend() async {
        print("🔄 Loading drill groups from backend...")
        
        do {
            // First load all drill groups
            let groups = try await DrillGroupService.shared.getAllDrillGroups()
            print("📋 Received \(groups.count) drill groups from backend")
            
            // Clear existing groups
            savedDrills = []
            groupBackendIds = [:]
            
            // Process each group
            for remoteGroup in groups {
                let groupId = UUID()
                
                // Create a local group from backend data
                let localGroup = GroupModel(
                    id: groupId,
                    name: remoteGroup.name,
                    description: remoteGroup.description,
                    drills: remoteGroup.drills.map { drillResponse in
                        DrillModel(
                            id: UUID(),
                            backendId: drillResponse.id,
                            title: drillResponse.title,
                            skill: drillResponse.type,
                            sets: drillResponse.sets ?? 0,
                            reps: drillResponse.reps ?? 0,
                            duration: drillResponse.duration,
                            description: drillResponse.description,
                            tips: drillResponse.tips,
                            equipment: drillResponse.equipment,
                            trainingStyle: drillResponse.intensity,
                            difficulty: drillResponse.difficulty
                        )
                    }
                )
                
                // Store backend ID mapping
                groupBackendIds[groupId] = remoteGroup.id
                
                // Add to saved drills if not a liked group
                if remoteGroup.name != "Liked Drills" {
                    savedDrills.append(localGroup)
                } else {
                    // Update liked drills group
                    likedDrillsGroup = localGroup
                    likedGroupBackendId = remoteGroup.id
                }
            }
            
            print("✅ Successfully loaded and processed drill groups")
        } catch {
            print("❌ Error loading drill groups from backend: \(error)")
        }
    }
}
