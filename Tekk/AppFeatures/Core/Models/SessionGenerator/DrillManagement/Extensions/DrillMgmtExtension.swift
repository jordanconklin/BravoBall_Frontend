//
//  DrillMgmtExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//

import Foundation

// DrillSelection protocol functions for sesgenmodel extension
extension SessionGeneratorModel: DrillSelection {
    
    // MARK: - Drill Selection Methods
    func drillsToAdd(drill: DrillModel) {
        if selectedDrills.contains(drill) {
            selectedDrills.removeAll(where: { $0.id == drill.id })
        } else {
            selectedDrills.append(drill)
        }
    }
    
    func isDrillSelected(_ drill: DrillModel) -> Bool {
        selectedDrills.contains(drill)
    }
    
    func addDrillToSession(drills: [DrillModel]) {
        for oneDrill in drills {
            let editableDrills = EditableDrillModel(
                drill: oneDrill,
                setsDone: 0,
                totalSets: oneDrill.sets,
                totalReps: oneDrill.reps,
                totalDuration: oneDrill.duration,
                isCompleted: false
            )
            if !orderedSessionDrills.contains(where: {$0.drill.id == oneDrill.id}) {
                orderedSessionDrills.append(editableDrills)
            }
        }
        
        if !selectedDrills.isEmpty {
            selectedDrills.removeAll()
        }
    }
}

