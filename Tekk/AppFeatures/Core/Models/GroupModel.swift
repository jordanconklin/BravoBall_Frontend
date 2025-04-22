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
            tips: drillResponse.tips,
            equipment: drillResponse.equipment,
            trainingStyle: drillResponse.intensity,
            difficulty: drillResponse.difficulty
        )
    }
) 