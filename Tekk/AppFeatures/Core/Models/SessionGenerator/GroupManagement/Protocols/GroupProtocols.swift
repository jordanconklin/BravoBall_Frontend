//
//  GroupProtocols.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//

import Foundation

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
