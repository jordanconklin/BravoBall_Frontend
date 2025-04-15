//
//  SessionDrillMgmtExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//

import Foundation

// MARK: - SessionDrillManagement Extension
extension SessionGeneratorModel: SessionDrillManagement {
    
    // MARK: - Session Management Methods
    func clearOrderedDrills() {
        orderedSessionDrills.removeAll()
    }
    
    func moveDrill(from source: IndexSet, to destination: Int) {
        orderedSessionDrills.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteDrillFromSession(drill: EditableDrillModel) {
        orderedSessionDrills.removeAll(where: { $0.drill.id == drill.drill.id })
    }
    
    func sessionNotComplete() -> Bool {
        orderedSessionDrills.contains(where: { $0.isCompleted == false })
    }
    
    func sessionsLeftToComplete() -> Int {
        orderedSessionDrills.count(where: {$0.isCompleted == false})
    }
    
    func updateDrills() {
        // Only update drills if the array is empty
        if orderedSessionDrills.isEmpty {
            // Show drills that match any of the selected sub-skills
            let filteredDrills = Self.testDrills.filter { drill in
                // Check if any of the selected skills match the drill
                for skill in selectedSkills {
                    // Match drills based on skill keywords
                    switch skill.lowercased() {
                    case "short passing":
                        if drill.title.contains("Short Passing") { return true }
                    case "long passing":
                        if drill.title.contains("Long Passing") { return true }
                    case "through balls":
                        if drill.title.contains("Through Ball") { return true }
                    case "power shots", "finesse shots", "volleys", "one-on-one finishing", "long shots":
                        if drill.title.contains("Shot") || drill.title.contains("Shooting") { return true }
                    case "close control", "speed dribbling", "1v1 moves", "winger skills", "ball mastery":
                        if drill.title.contains("Dribbling") || drill.title.contains("1v1") { return true }
                    default:
                        // For any other skills, try to match based on the first word
                        let mainSkill = skill.split(separator: " ").first?.lowercased() ?? ""
                        if drill.title.lowercased().contains(mainSkill) { return true }
                    }
                }
                return false
            }
            
            // Convert filtered DrillModels to EditableDrillModels
            orderedSessionDrills = filteredDrills.map { drill in
                EditableDrillModel(
                    drill: drill,
                    setsDone: 0,
                    totalSets: drill.sets,
                    totalReps: drill.reps,
                    totalDuration: drill.duration,
                    isCompleted: false
                )
            }
        } else {
            print("ℹ️ Skipping drill update as drills are already loaded")
        }
    }
}
