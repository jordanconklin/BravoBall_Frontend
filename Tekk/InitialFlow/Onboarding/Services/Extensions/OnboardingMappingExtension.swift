//
//  OnboardingMappingExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/2/25.
//

extension OnboardingService {
    // Maps frontend values to backend enum values
    static func mapPrimaryGoalForBackend(_ goal: String) -> String {
        let goalMap = [
            "Improve my overall skill level": "improve_skill",
            "Be the best player on my team": "best_on_team",
            "Get scouted for college": "college_scouting",
            "Become a professional player": "go_pro",
            "Have fun playing soccer": "have_fun"
        ]
        
        return goalMap[goal] ?? "improve_skill"
    }
    
    static func mapChallengeForBackend(_ challenges: [String]) -> [String] {
        let challengeMap = [
            "Not enough time to train": "lack_of_time",
            "Lack of proper training equipment": "lack_of_equipment",
            "Not knowing what to work on": "unsure_focus",
            "Staying motivated": "motivation",
            "Recovering from injury": "injury",
            "No team to play with": "no_team"
        ]
        
        return challenges.compactMap { challengeMap[$0] }
    }
    
    static func mapExperienceLevelForBackend(_ level: String) -> String {
        let levelMap = [
            "Beginner": "beginner",
            "Intermediate": "intermediate",
            "Advanced": "advanced",
            "Professional": "professional"
        ]
        
        return levelMap[level] ?? "unesure_experience"
    }
    
    static func mapPositionForBackend(_ position: String) -> String {
        let positionMap = [
            "Goalkeeper": "goalkeeper",
            "Fullback": "fullback",
            "Center-back": "center_back",
            "Defensive midfielder": "defensive_mid",
            "Central midfielder": "center_mid",
            "Attacking midfielder": "attacking_mid",
            "Winger": "winger",
            "Striker": "striker"
        ]
        
        return positionMap[position] ?? "unsure_position"
    }
    
    static func mapAgeRangeForBackend(_ ageRange: String) -> String {
        let ageMap = [
            "Under 12": "youth",
            "13–16": "teen",
            "17–19": "junior",
            "20–29": "adult",
            "30+": "senior"
        ]
        
        return ageMap[ageRange] ?? "adult"
    }
    
    static func mapSkillsForBackend(_ skills: [String]) -> [String] {
        let skillMap = [
            "Passing": "passing",
            "Dribbling": "dribbling",
            "Shooting": "shooting",
            "Defending": "defending",
            "First touch": "first_touch",
            "Fitness": "fitness"
        ]
        
        return skills.compactMap { skillMap[$0] ?? $0.lowercased().replacingOccurrences(of: " ", with: "_") }
    }
    
    static func mapTrainingLocationForBackend(_ locations: [String]) -> [String] {
        let locationMap = [
            "Full-sized field": "full_field",
            "Small field or park": "small_field",
            "At a gym or indoor court": "indoor_court",
            "In my backyard": "backyard",
            "Small indoor space": "small_room"
        ]
        
        return locations.compactMap { locationMap[$0] }
    }
    
    static func mapEquipmentForBackend(_ equipment: [String]) -> [String] {
        let equipmentMap = [
            "Soccer ball": "ball",
            "Cones": "cones",
            "Wall": "wall",
            "Goals": "goals"
        ]
        
        return equipment.compactMap { equipmentMap[$0] }
    }
    
    static func mapTrainingDurationForBackend(_ duration: String) -> String {
        let durationMap = [
            "Less than 30 minutes": "15",
            "30-60 minutes": "30",
            "60-90 minutes": "60",
            "More than 90 minutes": "90"
        ]
        
        return durationMap[duration] ?? "30"
    }
    
    static func mapTrainingFrequencyForBackend(_ frequency: String) -> String {
        let frequencyMap = [
            "1-2 days (light schedule)": "light",
            "3-5 days (moderate schedule)": "moderate",
            "6-7 days (intense schedule)": "intense"
        ]
        
        return frequencyMap[frequency] ?? "moderate"
    }
}
