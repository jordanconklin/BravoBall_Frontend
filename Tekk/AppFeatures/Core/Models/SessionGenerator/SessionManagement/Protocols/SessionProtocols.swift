//
//  SessionProtocols.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//

import Foundation


// MARK: - Drill Selection Protocol
protocol DrillSelection: AnyObject {
    var selectedDrills: [DrillModel] { get set }
    var selectedDrillForEditing: EditableDrillModel? { get set }
    var recommendedDrills: [DrillModel] { get set }
    
    func drillsToAdd(drill: DrillModel)
    func isDrillSelected(_ drill: DrillModel) -> Bool
    func addDrillToSession(drills: [DrillModel])
}

// MARK: - Session Drill Management Protocol
protocol SessionDrillManagement: AnyObject {
    var orderedSessionDrills: [EditableDrillModel] { get set }
    
    func clearOrderedDrills()
    func moveDrill(from source: IndexSet, to destination: Int)
    func deleteDrillFromSession(drill: EditableDrillModel)
    func allSessionSetsNotComplete() -> Bool
    func sessionsLeftToComplete() -> Int
}


// MARK: - Combined Protocol
protocol SessionProtocols: DrillSelection, SessionDrillManagement {
    // This protocol combines all drill-related functionality
}

