//
//  DrillManagement.swift
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
    func sessionNotComplete() -> Bool
    func sessionsLeftToComplete() -> Int
    func updateDrills()
}

// MARK: - Drill Group Management Protocol
protocol DrillGroupManagement: AnyObject {
    var savedDrills: [GroupModel] { get set }
    var likedDrillsGroup: GroupModel { get set }
    
    func addDrillToGroup(drill: DrillModel, groupId: UUID)
    func toggleDrillLike(drillId: UUID, drill: DrillModel)
    func isDrillLiked(_ drill: DrillModel) -> Bool
    func checkDrillLikedStatus(drillId: Int) async -> Bool
    func loadDrillGroupsFromBackend() async
}

// MARK: - Combined Protocol
protocol DrillManagement: DrillSelection, SessionDrillManagement, DrillGroupManagement {
    // This protocol combines all drill-related functionality
    // Additional shared requirements can be added here if needed
}
