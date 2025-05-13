//
//  PreferencesUpdate.swift
//  BravoBall
//
//  Created by Joshua Conklin on 5/9/25.
//

import Foundation
import SwiftKeychainWrapper

// Structure to match the backend's expected format
struct SessionPreferencesRequest: Codable {
    let duration: Int
    let availableEquipment: [String]
    let trainingStyle: String?
    let trainingLocation: String?
    let difficulty: String?
    let targetSkills: [SkillPreference]
    
    struct SkillPreference: Codable {
        let category: String
        let subSkills: [String]
        
        enum CodingKeys: String, CodingKey {
            case category
            case subSkills = "sub_skills"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case duration
        case availableEquipment = "available_equipment"
        case trainingStyle = "training_style"
        case trainingLocation = "training_location"
        case difficulty
        case targetSkills = "target_skills"
    }
}

// Structure to match the backend's response format
struct PreferencesUpdateResponse: Codable {
    let status: String
    let message: String
    let data: SessionData?
    
    struct SessionData: Codable {
        let sessionId: Int
        let totalDuration: Int
        let focusAreas: [String]
        let drills: [DrillResponse]
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case data
    }
}

class PreferencesUpdateService {
    static let shared = PreferencesUpdateService()
    private let baseURL = AppSettings.baseURL
    
    private init() {}
    
    func updatePreferences(
        time: String?,
        equipment: Set<String>,
        trainingStyle: String?,
        location: String?,
        difficulty: String?,
        skills: Set<String>,
        sessionModel: SessionGeneratorModel
    ) async throws {
        let url = URL(string: "\(baseURL)/api/session/preferences")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using auth token: \(token)")
        } else {
            print("⚠️ No auth token found!")
            throw URLError(.userAuthenticationRequired)
        }
        
        // Convert time string to minutes
        let duration = convertTimeToMinutes(time)
        
        // Print selected skills before conversion
        print("🟡 Selected skills before conversion: \(skills)")
        // Convert skills to the required format
        let targetSkills = convertSkillsToPreferences(skills)
        // Print targetSkills after conversion
        print("🟢 targetSkills after conversion: \(targetSkills)")
        
        // Create the request body
        let preferencesRequest = SessionPreferencesRequest(
            duration: duration,
            availableEquipment: Array(equipment),
            trainingStyle: trainingStyle,
            trainingLocation: location,
            difficulty: difficulty,
            targetSkills: targetSkills
        )
        
        // Encode the request body
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(preferencesRequest)
        
        print("📤 Updating preferences at: \(url.absoluteString)")
        print("Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw URLError(.badServerResponse)
        }
        
        print("📥 Response status code: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response body: \(responseString)")
        }
        
        switch httpResponse.statusCode {
        case 200:
            print("✅ Successfully updated preferences")
            // Decode the response
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(PreferencesUpdateResponse.self, from: data)
            
            // If we received a session, load it
            if let sessionData = response.data {
                print("✅ Received new session with \(sessionData.drills.count) drills")
                let session = SessionResponse(
                    sessionId: sessionData.sessionId,
                    totalDuration: sessionData.totalDuration,
                    focusAreas: sessionData.focusAreas,
                    drills: sessionData.drills
                )
                await MainActor.run {
                    sessionModel.loadInitialSession(from: session)
                }
            } else {
                print("⚠️ No session received in response")
            }
        case 401:
            print("❌ Unauthorized - Invalid or expired token")
            throw URLError(.userAuthenticationRequired)
        case 404:
            print("❌ User not found")
            throw URLError(.badURL)
        case 422:
            print("❌ Invalid request data")
            throw URLError(.badServerResponse)
        default:
            print("❌ Unexpected status code: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
    }
    
    // Helper function to convert time string to minutes
    private func convertTimeToMinutes(_ time: String?) -> Int {
        guard let time = time else { return 60 } // Default to 1 hour
        
        switch time {
        case "15min": return 15
        case "30min": return 30
        case "45min": return 45
        case "1h": return 60
        case "1h30": return 90
        case "2h+": return 120
        default: return 60
        }
    }
    
    // Helper function to convert skills to the required format
    private func convertSkillsToPreferences(_ skills: Set<String>) -> [SessionPreferencesRequest.SkillPreference] {
        // Group skills by their main category
        var skillsByCategory: [String: Set<String>] = [:]
        
        for skill in skills {
            // Split the skill into category and sub-skill using '-'
            let components = skill.split(separator: "-")
            if components.count >= 2 {
                let category = String(components[0])
                let subSkill = components.dropFirst().joined(separator: "-")
                
                if skillsByCategory[category] == nil {
                    skillsByCategory[category] = []
                }
                skillsByCategory[category]?.insert(subSkill)
            }
        }
        
        // Convert to the required format
        return skillsByCategory.map { category, subSkills in
            SessionPreferencesRequest.SkillPreference(
                category: category,
                subSkills: Array(subSkills)
            )
        }
    }
}

