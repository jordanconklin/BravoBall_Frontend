//
//  ResponseModels.swift
//  BravoBall
//
//  Created by Jordan on 5/15/25.
//
import SwiftUI

// TODO need to simplify, should not need these models

// Add the SessionResponse model definition directly in this file
struct SessionResponse: Codable {
    let sessionId: Int?
    let totalDuration: Int
    let focusAreas: [String]
    let drills: [DrillResponse]
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case totalDuration = "total_duration"
        case focusAreas = "focus_areas"
        case drills
    }
}



// Add the DrillResponse model definition
//TODO: have backend send othe needed data types (e.g. thumbnail URL) it is accepting
struct DrillResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let duration: Int
    let intensity: String
    let difficulty: String
    let equipment: [String]
    let suitableLocations: [String]
    let instructions: [String]
    let tips: [String]
    let type: String
    let sets: Int?  // Make sets optional to handle null values
    let reps: Int?  // Make reps optional to handle null values
    let rest: Int?
    let primarySkill: DrillResponse.Skill?
    let secondarySkills: [DrillResponse.Skill]?
    let videoURL: String?
    
    struct Skill: Codable, Hashable {
            let category: String
            let subSkill: String
            
            enum CodingKeys: String, CodingKey {
                case category
                case subSkill = "sub_skill"
            }
        }
    
    // enums to handle sanke_case and camelCase differences from frontend and backend
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case duration
        case intensity
        case difficulty
        case equipment
        case suitableLocations = "suitable_locations"
        case instructions
        case tips
        case type
        case sets
        case reps
        case rest
        case primarySkill = "primary_skill"
        case secondarySkills = "secondary_skills"
        case videoURL = "video_url"
    }
    
    // Convert API response to local DrillModel
    func toDrillModel() -> DrillModel {
        // Get the primary skill category, defaulting to the type if not available
        let skillCategory = primarySkill?.category ?? type
        
        // Collect all sub-skills from both primary and secondary skills
        var allSubSkills: [String] = []
        if let primarySubSkill = primarySkill?.subSkill {
            allSubSkills.append(primarySubSkill)
        }
        if let secondarySkills = secondarySkills {
            allSubSkills.append(contentsOf: secondarySkills.map { $0.subSkill })
        }
        
        return DrillModel(
            id: UUID(),  // Generate a new UUID since we can't convert an Int to UUID
            backendId: id, // Store the backend ID from the API
            title: title,
            skill: skillCategory,
            subSkills: allSubSkills,
            sets: sets ?? 0,
            reps: reps ?? 0,
            duration: duration,
            description: description,
            instructions: instructions,
            tips: tips,
            equipment: equipment,
            trainingStyle: intensity,
            difficulty: difficulty,
            videoURL: videoURL
        )
    }
    
    // Custom initializer to handle decoding with null values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields with default values if missing or null
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Unnamed Drill"
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        
        // Handle null durations
        if let durationValue = try? container.decode(Int.self, forKey: .duration) {
            duration = durationValue
        } else {
            duration = 10 // Default value
        }
        
        intensity = try container.decodeIfPresent(String.self, forKey: .intensity) ?? "medium"
        difficulty = try container.decodeIfPresent(String.self, forKey: .difficulty) ?? "beginner"
        
        // Handle array fields
        equipment = try container.decodeIfPresent([String].self, forKey: .equipment) ?? []
        suitableLocations = try container.decodeIfPresent([String].self, forKey: .suitableLocations) ?? []
        instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []
        tips = try container.decodeIfPresent([String].self, forKey: .tips) ?? []
        
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? "other"
        
        
        // Optional fields
        sets = try container.decodeIfPresent(Int.self, forKey: .sets)
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)
        rest = try container.decodeIfPresent(Int.self, forKey: .rest)
        
        primarySkill = try container.decodeIfPresent(Skill.self, forKey: .primarySkill)
        secondarySkills = try container.decodeIfPresent([Skill].self, forKey: .secondarySkills)
        videoURL = try container.decodeIfPresent(String.self, forKey: .videoURL)
    }
    
    // Standard initializer for creating instances directly
    init(id: Int, title: String, description: String, duration: Int, intensity: String, difficulty: String, equipment: [String], suitableLocations: [String], instructions: [String], tips: [String], type: String, sets: Int?, reps: Int?, rest: Int?, primarySkill: Skill?, secondarySkills: [Skill]?, videoURL: String?) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.intensity = intensity
        self.difficulty = difficulty
        self.equipment = equipment
        self.suitableLocations = suitableLocations
        self.instructions = instructions
        self.tips = tips
        self.type = type
        self.sets = sets
        self.reps = reps
        self.rest = rest
        self.primarySkill = primarySkill
        self.secondarySkills = secondarySkills
        self.videoURL = videoURL
    }
    
    // Map API skill types to app skill types
    private func mapSkillType(_ apiType: String) -> String {
        let skillMap = [
            "passing": "Passing",
            "shooting": "Shooting",
            "dribbling": "Dribbling",
            "first_touch": "First touch",
            "fitness": "Fitness",
            "defending": "Defending",
            "set_based": "Set-based",
            "reps_based": "Reps-based"
        ]
        
        return skillMap[apiType.lowercased()] ?? apiType
    }
}
