//
//  OnboardingService.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/8/25.
//

import Foundation


// Define the structure for the onboarding response
struct OnboardingResponse: Codable {
    let status: String
    let message: String
    let access_token: String
    let refresh_token: String?
    let tokenType: String
    let userId: Int
    let initialSession: SessionResponse?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case access_token
        case refresh_token
        case tokenType = "token_type"
        case userId = "user_id"
        case initialSession = "initial_session"
    }
}

// Submits onboarding data to the backend and stores access token in OnboardingResponse
class OnboardingService {
    static let shared = OnboardingService()
    static let appSettings = AppSettings()
    
    func submitOnboardingData(data: OnboardingModel.OnboardingData, completion: @escaping (Result<OnboardingResponse, Error>) -> Void) {
    
        // Create the request body
        let requestBody: [String: Any] = [
            "firstName": data.firstName,
            "lastName": data.lastName,
            "email": data.email,
            "password": data.password,
            "primaryGoal": OnboardingService.mapPrimaryGoalForBackend(data.primaryGoal),
            "biggestChallenge": OnboardingService.mapChallengeForBackend(data.biggestChallenge),
            "trainingExperience": OnboardingService.mapExperienceLevelForBackend(data.trainingExperience),
            "position": OnboardingService.mapPositionForBackend(data.position),
            "playstyle": data.playstyle,
            "ageRange": OnboardingService.mapAgeRangeForBackend(data.ageRange),
            "strengths": OnboardingService.mapSkillsForBackend(data.strengths),
            "areasToImprove": OnboardingService.mapSkillsForBackend(data.areasToImprove),
            "trainingLocation": OnboardingService.mapTrainingLocationForBackend(data.trainingLocation),
            "availableEquipment": OnboardingService.mapEquipmentForBackend(data.availableEquipment.isEmpty ? ["Soccer ball"] : data.availableEquipment),
            "dailyTrainingTime": OnboardingService.mapTrainingDurationForBackend(data.dailyTrainingTime),
            "weeklyTrainingDays": OnboardingService.mapTrainingFrequencyForBackend(data.weeklyTrainingDays)
        ]
 
        // Convert to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "OnboardingService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request body"])))
            return
        }
        Task {
            do {
                let (data, response) = try await APIService.shared.request(
                    endpoint: "/api/onboarding",
                    method: "POST",
                    headers: ["Content-Type": "application/json"],
                    body: jsonData
                )
                guard response.statusCode == 200 else {
                    completion(.failure(NSError(domain: "OnboardingService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(response.statusCode)"])))
                    return
                }
                let decoder = JSONDecoder()
                let onboardingResponse = try decoder.decode(OnboardingResponse.self, from: data)
                completion(.success(onboardingResponse))
            } catch {
                completion(.failure(error))
            }
        }
    }
    

    // Add an async version of the submitOnboardingData method
    func submitOnboardingData(data: OnboardingModel.OnboardingData) async throws -> OnboardingResponse {
        print("📤 Sending onboarding data: \(data)")
        let requestBody: [String: Any] = [
            "firstName": data.firstName,
            "lastName": data.lastName,
            "email": data.email,
            "password": data.password,
            "primaryGoal": OnboardingService.mapPrimaryGoalForBackend(data.primaryGoal),
            "biggestChallenge": OnboardingService.mapChallengeForBackend(data.biggestChallenge),
            "trainingExperience": OnboardingService.mapExperienceLevelForBackend(data.trainingExperience),
            "position": OnboardingService.mapPositionForBackend(data.position),
            "playstyle": data.playstyle,
            "ageRange": OnboardingService.mapAgeRangeForBackend(data.ageRange),
            "strengths": OnboardingService.mapSkillsForBackend(data.strengths),
            "areasToImprove": OnboardingService.mapSkillsForBackend(data.areasToImprove),
            "trainingLocation": OnboardingService.mapTrainingLocationForBackend(data.trainingLocation),
            "availableEquipment": OnboardingService.mapEquipmentForBackend(data.availableEquipment.isEmpty ? ["Soccer ball"] : data.availableEquipment),
            "dailyTrainingTime": OnboardingService.mapTrainingDurationForBackend(data.dailyTrainingTime),
            "weeklyTrainingDays": OnboardingService.mapTrainingFrequencyForBackend(data.weeklyTrainingDays)
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        let (data, response) = try await APIService.shared.request(
            endpoint: "/api/onboarding",
            method: "POST",
            headers: ["Content-Type": "application/json"],
            body: jsonData
        )
        guard response.statusCode == 200 else {
            throw NSError(domain: "OnboardingService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(response.statusCode)"])
        }
        let decoder = JSONDecoder()
        let onboardingResponse = try decoder.decode(OnboardingResponse.self, from: data)
        return onboardingResponse
    }
}

// MARK: - Value Mapping Extensions
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
            "Youth (8-12)": "youth",
            "Teen (13-16)": "teen",
            "Junior (17-19)": "junior",
            "Adult (20-29)": "adult",
            "Senior (30+)": "senior"
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
