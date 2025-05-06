//
//  SessionGeneratorModel+InitialSession.swift
//  BravoBall
//
//  Created by Jordan on 4/18/25.
//

import Foundation

// MARK: - Initial Session Loading Extension
extension SessionGeneratorModel {
    func loadInitialSession(from sessionResponse: SessionResponse) {
        print("🔄 Loading initial session with \(sessionResponse.drills.count) drills")
        
        // Clear any existing drills
        orderedSessionDrills.removeAll()
        
        // Validate the session response
        guard !sessionResponse.drills.isEmpty else {
            print("⚠️ No drills found in the initial session response")
            addDefaultDrills()
            return
        }
        
        // Convert API drills to app's drill models and add them to orderedDrills
        for apiDrill in sessionResponse.drills {
            print("📋 Processing drill: \(apiDrill.title)")
            let drillModel = apiDrill.toDrillModel()
            
            // Create an editable drill model
            let editableDrill = EditableDrillModel(
                drill: drillModel,
                setsDone: 0,
                totalSets: drillModel.sets,
                totalReps: drillModel.reps,
                totalDuration: drillModel.duration,
                isCompleted: false
            )
            
            // Add to ordered drills
            orderedSessionDrills.append(editableDrill)
            print("✅ Added drill: \(drillModel.title) (Sets: \(drillModel.sets), Reps: \(drillModel.reps))")
        }
        
        print("✅ Added \(orderedSessionDrills.count) drills to session")
        
        // Update selected skills based on focus areas
        selectedSkills.removeAll()
        for skill in sessionResponse.focusAreas {
            print("🎯 Adding focus area: \(skill)")
            // Map backend skill names to frontend skill names
            let mappedSkill = mapBackendSkillToFrontend(skill)
            selectedSkills.insert(mappedSkill)
        }
        
        print("✅ Updated selected skills: \(selectedSkills)")
        
        // Save the session to cache
        cacheOrderedDrills()
        saveChanges()
        print("💾 Saved session to cache")
        
        // If no drills were loaded, add some default drills
        if orderedSessionDrills.isEmpty {
            print("⚠️ No drills were loaded from the initial session, adding default drills")
            addDefaultDrills()
        }
    }
    
    private func mapBackendSkillToFrontend(_ backendSkill: String) -> String {
        let skillMap = [
            "passing": "Passing",
            "dribbling": "Dribbling",
            "shooting": "Shooting",
            "defending": "Defending",
            "first_touch": "First touch",
            "fitness": "Fitness"
        ]
        
        return skillMap[backendSkill.lowercased()] ?? backendSkill.capitalized
    }
    
    private func addDefaultDrills() {
        // Add a few default drills based on the selected skills
        let defaultDrills = SessionGeneratorModel.testDrills.filter { drill in
            return selectedSkills.contains(drill.skill) || selectedSkills.isEmpty
        }
        
        for drill in defaultDrills.prefix(3) {
            let editableDrill = EditableDrillModel(
                drill: drill,
                setsDone: 0,
                totalSets: drill.sets,
                totalReps: drill.reps,
                totalDuration: drill.duration,
                isCompleted: false
            )
            
            orderedSessionDrills.append(editableDrill)
        }
        
        print("✅ Added \(orderedSessionDrills.count) default drills to session")
        saveChanges()
    }
} 
