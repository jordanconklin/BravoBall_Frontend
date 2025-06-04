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
        
//        if appSettings.useMockData {
//            return createMockResponse()
//        }
//        
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
        
        // Create URL request
        guard let url = URL(string: "\(AppSettings.baseURL)/api/onboarding") else {
            completion(.failure(NSError(domain: "OnboardingService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Make the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "OnboardingService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                // For debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }
                
                let decoder = JSONDecoder()
                let response = try decoder.decode(OnboardingResponse.self, from: data)
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
//    // Use this to simulate what the backend might return
//    private func createMockResponse() -> OnboardingResponse {
//        // Create mock drill responses
//        let mockDrills = [
//            DrillResponse(
//                id: 1,
//                title: "V-Passes",
//                description: "A passing drill focusing on quick directional changes and control.",
//                duration: 15,
//                intensity: "high",
//                difficulty: "intermediate",
//                equipment: ["ball", "wall", "cones"],
//                suitableLocations: ["indoor_court", "backyard"],
//                instructions: ["Stand 5 yards away from a wall.", "Set two cones 2 yards apart in a horizontal line."],
//                tips: ["Keep a low stance for quick lateral movement."],
//                type: "passing",
//                sets: 3,
//                reps: 20,
//                rest: 30
//            ),
//            DrillResponse(
//                id: 2,
//                title: "Dribbling Circuit",
//                description: "Improve close control and dribbling skills.",
//                duration: 20,
//                intensity: "medium",
//                difficulty: "beginner",
//                equipment: ["ball", "cones"],
//                suitableLocations: ["indoor_court", "small_field"],
//                instructions: ["Set up cones in a zigzag pattern.", "Dribble through the cones using both feet."],
//                tips: ["Focus on keeping the ball close to your feet."],
//                type: "dribbling",
//                sets: 4,
//                reps: 10,
//                rest: 45
//            )
//        ]
//        
//        // Create a mock session response
//        let mockSession = SessionResponse(
//            sessionId: 123,
//            totalDuration: 45,
//            focusAreas: data.areasToImprove.isEmpty ? ["passing", "dribbling"] : OnboardingService.mapSkillsForBackend(data.areasToImprove),
//            drills: mockDrills
//        )
        
//        // Create and return the full onboarding response
//        return OnboardingResponse(
//            status: "success",
//            message: "Onboarding completed successfully",
//            access_token: "mock_token_12345",
//            tokenType: "Bearer",
//            userId: 42,
//            initialSession: mockSession
//        )
//    }

    // Add an async version of the submitOnboardingData method
    func submitOnboardingData(data: OnboardingModel.OnboardingData) async throws -> OnboardingResponse {
        // Print the original data
        print("📤 Sending onboarding data: \(data)")
        
        // Print the mapped data for debugging
        let mappedData: [String: Any] = [
            "primaryGoal": OnboardingService.mapPrimaryGoalForBackend(data.primaryGoal),
            "biggestChallenge": OnboardingService.mapChallengeForBackend(data.biggestChallenge),
            "trainingExperience": OnboardingService.mapExperienceLevelForBackend(data.trainingExperience),
            "position": OnboardingService.mapPositionForBackend(data.position),
            "ageRange": OnboardingService.mapAgeRangeForBackend(data.ageRange),
            "strengths": OnboardingService.mapSkillsForBackend(data.strengths),
            "areasToImprove": OnboardingService.mapSkillsForBackend(data.areasToImprove),
            "trainingLocation": OnboardingService.mapTrainingLocationForBackend(data.trainingLocation),
            "availableEquipment": OnboardingService.mapEquipmentForBackend(data.availableEquipment.isEmpty ? ["Soccer ball"] : data.availableEquipment)
        ]
        print("🔄 Mapped data for backend: \(mappedData)")
        
        return try await withCheckedThrowingContinuation { continuation in
            submitOnboardingData(data: data) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
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
