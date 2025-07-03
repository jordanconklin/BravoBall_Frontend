//
//  BothGroupsExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//


import Foundation

// MARK: - DrillGroupManagement Extension
extension SessionGeneratorModel: BothGroupsManagement {
    

    @MainActor
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
                        
                        let skillCategory = drillResponse.primarySkill?.category ?? drillResponse.type
                        
                        // Collect all sub-skills from both primary and secondary skills
                        var allSubSkills: [String] = []
                        if let primarySubSkill = drillResponse.primarySkill?.subSkill {
                            allSubSkills.append(primarySubSkill)
                        }
                        if let secondarySkills = drillResponse.secondarySkills {
                            allSubSkills.append(contentsOf: secondarySkills.map { $0.subSkill })
                        }
                        
                        return DrillModel(
                            id: UUID(),
                            backendId: drillResponse.id,
                            title: drillResponse.title,
                            skill: skillCategory,
                            subSkills: allSubSkills,
                            sets: drillResponse.sets ?? 0,
                            reps: drillResponse.reps ?? 0,
                            duration: drillResponse.duration,
                            description: drillResponse.description,
                            instructions: drillResponse.instructions,
                            tips: drillResponse.tips,
                            equipment: drillResponse.equipment,
                            trainingStyle: drillResponse.intensity,
                            difficulty: drillResponse.difficulty,
                            videoUrl: drillResponse.videoUrl
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
