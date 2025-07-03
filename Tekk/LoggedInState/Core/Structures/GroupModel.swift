//
//  GroupModel.swift
//  BravoBall
//
//  Created by Joshua Conklin on 3/7/25.
//

import Foundation

struct GroupModel: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    var drills: [DrillModel]
    
    init(id: UUID = UUID(), name: String, description: String, drills: [DrillModel]) {
        self.id = id
        self.name = name
        self.description = description
        self.drills = drills
    }
} 
