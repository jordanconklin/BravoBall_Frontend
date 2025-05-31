//
//  SkillTypes.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import Foundation

enum SkillType: String, CaseIterable {
    case passing = "Passing"
    case dribbling = "Dribbling"
    case shooting = "Shooting"
    case firstTouch = "First Touch"
    case crossing = "Crossing"
    case defending = "Defending"
    case goalkeeping = "Goalkeeping"
}

struct SkillCategory {
    let name: String
    let subSkills: [String]
    let icon: String
}


extension SessionGeneratorView {
    // Define all available skill categories and their sub-skills
    static let skillCategories: [SkillCategory] = [
        SkillCategory(name: "Passing", subSkills: [
            "Short passing",
            "Long passing",
            "One touch passing",
            "Technique",
            "Passing with movement"
        ], icon: "figure.soccer"),
        
        SkillCategory(name: "Shooting", subSkills: [
            "Power shots",
            "Finesse shots",
            "First time shots",
            "1v1 to shoot",
            "Shooting on the run",
            "Volleying"
        ], icon: "figure.soccer"),
        
        SkillCategory(name: "Dribbling", subSkills: [
            "Close control",
            "Speed dribbling",
            "1v1 moves",
            "Change of direction",
            "Ball mastery"
        ], icon: "figure.walk"),
        
        SkillCategory(name: "First Touch", subSkills: [
            "Ground control",
            "Aerial control",
            "Turn with ball",
            "Touch and move",
            "Juggling"
        ], icon: "figure.stand")
    ]
}
