//
//  DrillStruct.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/3/25.
//

import Foundation

// Drill model
struct DrillModel: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    let backendId: Int? // Backend ID from database (between 1-79)
    let title: String
    let skill: String
    let subSkills: [String]
    let sets: Int
    let reps: Int
    let duration: Int
    let description: String
    let instructions: [String]
    let tips: [String]
    let equipment: [String]
    let trainingStyle: String
    let difficulty: String
    let videoUrl: String
    
    init(id: UUID = UUID(),  // Adding initializer with default UUID
         backendId: Int? = nil, // Add backend ID parameter
         title: String,
         skill: String,
         subSkills: [String],
         sets: Int = 0,  // Make sets optional with default value of 0
         reps: Int = 0,  // Make reps optional with default value of 0
         duration: Int,
         description: String,
         instructions: [String],
         tips: [String],
         equipment: [String],
         trainingStyle: String,
         difficulty: String,
         videoUrl: String) {
        self.id = id
        self.backendId = backendId
        self.title = title
        self.skill = skill
        self.subSkills = subSkills
        self.sets = sets
        self.reps = reps
        self.duration = duration
        self.description = description
        self.instructions = instructions
        self.tips = tips
        self.equipment = equipment
        self.trainingStyle = trainingStyle
        self.difficulty = difficulty
        self.videoUrl = videoUrl
    }
    
    static func == (lhs: DrillModel, rhs: DrillModel) -> Bool {
        lhs.id == rhs.id
    }
}
