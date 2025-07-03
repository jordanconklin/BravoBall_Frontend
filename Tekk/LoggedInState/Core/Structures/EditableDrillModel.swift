//
//  EditableDrillModel.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import Foundation

struct EditableDrillModel: Codable, Equatable {
    var drill: DrillModel
    var setsDone: Int
    var totalSets: Int
    var totalReps: Int
    var totalDuration: Int
    var isCompleted: Bool
    
    static func == (lhs: EditableDrillModel, rhs: EditableDrillModel) -> Bool {
        return lhs.drill.id == rhs.drill.id &&
               lhs.setsDone == rhs.setsDone &&
               lhs.totalSets == rhs.totalSets &&
               lhs.totalReps == rhs.totalReps &&
               lhs.totalDuration == rhs.totalDuration &&
               lhs.isCompleted == rhs.isCompleted
    }
}

