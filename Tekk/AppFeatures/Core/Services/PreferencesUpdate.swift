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
    let targetSkills: [String]
    
    
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

// Structure to match the backend's response format for fetching preferences
struct PreferencesResponse: Codable {
    let status: String
    let message: String
    let data: PreferencesData
    
    struct PreferencesData: Codable {
        let duration: Int?
        let availableEquipment: [String]?
        let trainingStyle: String?
        let trainingLocation: String?
        let difficulty: String?
        let targetSkills: [String]?
        
       
        
        enum CodingKeys: String, CodingKey {
            case duration
            case availableEquipment = "available_equipment"
            case trainingStyle = "training_style"
            case trainingLocation = "training_location"
            case difficulty
            case targetSkills = "target_skills"
        }
    }
}

class PreferencesUpdateService {
    static let shared = PreferencesUpdateService()
    private let baseURL = AppSettings.baseURL
    
    private init() {}
    
    // Debounce properties
    private var debounceWorkItem: DispatchWorkItem?
    private let debounceInterval: TimeInterval = 1.0 // seconds
    private var lastUpdateTime: Date = Date()
    private let minimumUpdateInterval: TimeInterval = 1.0 // Minimum time between updates
    private var isUpdating = false // Track if an update is in progress

    // Update preferences using preference data and subskills, which will help load a session into the SessionGeneratorView
    func updatePreferences(time: String?, equipment: Set<String>, trainingStyle: String?, location: String?, difficulty: String?, skills: Set<String>, sessionModel: SessionGeneratorModel, isOnboarding: Bool = false) async throws {
        // If this is onboarding, skip debounce and update immediately
        if isOnboarding {
            print("[Onboarding] Performing immediate preferences update")
            try await performUpdatePreferences(time: time, equipment: equipment, trainingStyle: trainingStyle, location: location, difficulty: difficulty, skills: skills, sessionModel: sessionModel)
            return
        }

        print("Current access token: \(KeychainWrapper.standard.string(forKey: "accessToken") ?? "nil")")
        print("Current refresh token: \(KeychainWrapper.standard.string(forKey: "refreshToken") ?? "nil")")
        
        // Check if an update is already in progress
        guard !isUpdating else {
            print("[Debounce] Skipping update - another update is in progress")
            return
        }
        
        // Check if enough time has passed since last update
        let now = Date()
        guard now.timeIntervalSince(lastUpdateTime) >= minimumUpdateInterval else {
            print("[Debounce] Skipping update - too soon since last update")
            return
        }
        
        // Cancel any pending debounce work
        debounceWorkItem?.cancel()
        print("[Debounce] Cancelled previous pending updatePreferences call.")

        // Create a new work item
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            Task {
                print("[Debounce] Debounced updatePreferences call is now executing.")
                do {
                    self.isUpdating = true
                    try await self.performUpdatePreferences(time: time, equipment: equipment, trainingStyle: trainingStyle, location: location, difficulty: difficulty, skills: skills, sessionModel: sessionModel)
                    self.lastUpdateTime = Date()
                } catch {
                    print("[Debounce] Error in debounced updatePreferences: \(error)")
                }
                self.isUpdating = false
            }
        }
        
        debounceWorkItem = workItem
        print("[Debounce] Scheduled updatePreferences to run in \(debounceInterval) seconds.")
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
    }

    // The actual call-to-backend logic, extracted for debouncing
    private func performUpdatePreferences(time: String?, equipment: Set<String>, trainingStyle: String?, location: String?, difficulty: String?, skills: Set<String>, sessionModel: SessionGeneratorModel) async throws {
        let endpoint = "/api/session/preferences"
        let duration = convertTimeToMinutes(time)
        let preferencesRequest = SessionPreferencesRequest(
            duration: duration,
            availableEquipment: Array(equipment),
            trainingStyle: trainingStyle,
            trainingLocation: location,
            difficulty: difficulty,
            targetSkills: Array(skills)
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try encoder.encode(preferencesRequest)

        let (data, response) = try await APIService.shared.request(
            endpoint: endpoint,
            method: "PUT",
            headers: ["Content-Type": "application/json"],
            body: body
        )

        guard response.statusCode == 200 else {
            switch response.statusCode {
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
                print("❌ Unexpected status code: \(response.statusCode)")
                throw URLError(.badServerResponse)
            }
        }

        print("✅ Successfully updated preferences")
        // Manually parse the drills array from the JSON and construct DrillModel objects directly
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dataDict = json["data"] as? [String: Any],
           let sessionId = dataDict["session_id"] as? Int,
           let totalDuration = dataDict["total_duration"] as? Int,
           let focusAreas = dataDict["focus_areas"] as? [String],
           let drillsArray = dataDict["drills"] as? [[String: Any]] {
            let drillModels: [DrillModel] = drillsArray.map { drill in
                let id = UUID()
                let backendId = drill["id"] as? Int
                let title = drill["title"] as? String ?? "Unnamed Drill"
                let skill = drill["type"] as? String ?? "other"
                let subSkills: [String] = {
                    var allSubSkills: [String] = []
                    if let primarySkill = drill["primary_skill"] as? [String: Any],
                       let subSkill = primarySkill["sub_skill"] as? String {
                        allSubSkills.append(subSkill)
                    }
                    if let secondarySkills = drill["secondary_skills"] as? [[String: Any]] {
                        allSubSkills.append(contentsOf: secondarySkills.compactMap { $0["sub_skill"] as? String })
                    }
                    return allSubSkills
                }()
                let sets = drill["sets"] as? Int ?? 0
                let reps = drill["reps"] as? Int ?? 0
                let duration = drill["duration"] as? Int ?? 10
                let description = drill["description"] as? String ?? ""
                let instructions = drill["instructions"] as? [String] ?? []
                let tips = drill["tips"] as? [String] ?? []
                let equipment = drill["equipment"] as? [String] ?? []
                let trainingStyle = drill["intensity"] as? String ?? ""
                let difficulty = drill["difficulty"] as? String ?? ""
                let videoUrl = drill["video_url"] as? String ?? ""
                return DrillModel(
                    id: id,
                    backendId: backendId,
                    title: title,
                    skill: skill,
                    subSkills: subSkills,
                    sets: sets,
                    reps: reps,
                    duration: duration,
                    description: description,
                    instructions: instructions,
                    tips: tips,
                    equipment: equipment,
                    trainingStyle: trainingStyle,
                    difficulty: difficulty,
                    videoUrl: videoUrl
                )
            }
            let session = SessionResponse(
                sessionId: sessionId,
                totalDuration: totalDuration,
                focusAreas: focusAreas,
                drills: drillModels.map { drill in
                    DrillResponse(
                        id: drill.backendId ?? 0,
                        title: drill.title,
                        description: drill.description,
                        duration: drill.duration,
                        intensity: drill.trainingStyle,
                        difficulty: drill.difficulty,
                        equipment: drill.equipment,
                        suitableLocations: [],
                        instructions: drill.instructions,
                        tips: drill.tips,
                        type: drill.skill,
                        sets: drill.sets,
                        reps: drill.reps,
                        rest: nil,
                        primarySkill: nil,
                        secondarySkills: nil,
                        videoUrl: drill.videoUrl
                    )
                }
            )
            await MainActor.run {
                // Update the current session ID
                sessionModel.currentSessionId = sessionId
                print("✅ Updated current session ID to: \(sessionId)")
                
                sessionModel.orderedSessionDrills = drillModels.map { drill in
                    EditableDrillModel(
                        drill: drill,
                        setsDone: 0,
                        totalSets: drill.sets,
                        totalReps: drill.reps,
                        totalDuration: drill.duration,
                        isCompleted: false
                    )
                }
            }
        } else {
            print("❌ Failed to manually parse session response JSON")
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
    
    
    func fetchPreferences() async throws -> PreferencesResponse.PreferencesData {
        let endpoint = "/api/session/preferences"
        let (data, response) = try await APIService.shared.request(
            endpoint: endpoint,
            method: "GET",
            headers: ["Content-Type": "application/json"]
        )
        guard response.statusCode == 200 else {
            switch response.statusCode {
            case 401:
                print("❌ Unauthorized - Invalid or expired token")
                throw URLError(.userAuthenticationRequired)
            case 404:
                print("❌ Preferences not found")
                throw URLError(.badURL)
            default:
                print("❌ Unexpected status code: \(response.statusCode)")
                throw URLError(.badServerResponse)
            }
        }
        print("✅ Successfully fetched preferences")
        let decoder = JSONDecoder()
        let responseObj = try decoder.decode(PreferencesResponse.self, from: data)
        print("[DEBUG] Decoded preferences data: \(responseObj.data)")
        return responseObj.data
    }
    
    // Helper function to convert minutes to time string
    func convertMinutesToTimeString(_ minutes: Int) -> String {
        switch minutes {
        case 0...15: return "15min"
        case 16...30: return "30min"
        case 31...45: return "45min"
        case 46...60: return "1h"
        case 61...90: return "1h30"
        default: return "2h+"
        }
    }
    
}

