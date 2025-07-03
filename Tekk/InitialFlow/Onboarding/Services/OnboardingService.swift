//
//  OnboardingService.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/8/25.
//

import Foundation


// Submits onboarding data to the backend and stores access token in OnboardingResponse
class OnboardingService {
    static let shared = OnboardingService()
    static let appSettings = AppSettings()
    

    // Add an async version of the submitOnboardingData method
    func submitOnboardingData(data: OnboardingModel.OnboardingData) async throws -> OnboardingResponse {
        print("📤 Sending onboarding data: \(data)")
        let requestBody: [String: Any] = [
            "email": data.email,
            "password": data.password,
            "primaryGoal": OnboardingService.mapPrimaryGoalForBackend(data.primaryGoal),
            "trainingExperience": OnboardingService.mapExperienceLevelForBackend(data.trainingExperience),
            "position": OnboardingService.mapPositionForBackend(data.position),
            "ageRange": OnboardingService.mapAgeRangeForBackend(data.ageRange),
            "strengths": OnboardingService.mapSkillsForBackend(data.strengths),
            "areasToImprove": OnboardingService.mapSkillsForBackend(data.areasToImprove),
            // Include empty arrays for optional fields to maintain backend compatibility
            "biggestChallenge": [],
            "playstyle": [],
            "trainingLocation": [],
            "availableEquipment": ["Soccer ball"], // Default to just a soccer ball
            "dailyTrainingTime": "30", // Default to 30 minutes
            "weeklyTrainingDays": "moderate" // Default to moderate schedule
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
