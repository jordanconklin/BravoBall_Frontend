//
//  BothGroupsExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//


import Foundation

// MARK: - DrillGroupManagement Extension
extension SessionGeneratorModel: BothGroupsManagement {
    

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
                            subSkills: drillResponse.subSkills,
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
