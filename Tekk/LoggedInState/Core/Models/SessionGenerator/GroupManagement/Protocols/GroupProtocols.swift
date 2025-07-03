//
//  GroupProtocols.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//

import Foundation

// MARK: - Saved Drills Group Protocol
protocol SavedDrillsGroupManagement: AnyObject {
    var savedDrills: [GroupModel] { get set }
    
    func addDrillToGroup(drill: DrillModel, groupId: UUID)
    func loadDrillGroupsFromBackend() async
}

// MARK: - Liked Drills Protocol
protocol LikedDrillsManagement: AnyObject {
    var likedDrillsGroup: GroupModel { get set }
    
    func toggleDrillLike(drillId: UUID, drill: DrillModel)
    func isDrillLiked(_ drill: DrillModel) -> Bool
    func checkDrillLikedStatus(drillId: Int) async -> Bool
}

protocol BothGroupsManagement: AnyObject {
    
}

