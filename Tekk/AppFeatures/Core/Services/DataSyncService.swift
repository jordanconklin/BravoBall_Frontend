//
//  DataSyncService.swift
//  BravoBall
//
//  Created by Joshua Conklin on 3/12/25.
//

import Foundation
import SwiftKeychainWrapper

class DataSyncService {
    static let shared = DataSyncService()
    private let baseURL = AppSettings.baseURL
    
    
    // MARK: - Ordered Session Drills Sync
    
    func fetchOrderedDrills() async throws -> [EditableDrillModel] {
        let url = URL(string: "\(baseURL)/api/sessions/ordered_drills/")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using auth token: \(token)")
        } else {
            print("⚠️ No auth token found!")
            throw URLError(.userAuthenticationRequired)
        }
        
        print("📤 Fetching ordered drills from: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw URLError(.badServerResponse)
        }
        
        print("📥 Response status code: \(httpResponse.statusCode)")
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let drills = try decoder.decode([DrillResponse].self, from: data)
            
            // Convert API response to EditableDrillModel
            return drills.map { apiDrill in
                let drillModel = apiDrill.toDrillModel()
                return EditableDrillModel(
                    drill: drillModel,
                    setsDone: 0,
                    totalSets: drillModel.sets,
                    totalReps: drillModel.reps,
                    totalDuration: drillModel.duration,
                    isCompleted: false
                )
            }
        case 401:
            print("❌ Unauthorized - Invalid or expired token")
            throw URLError(.userAuthenticationRequired)
        case 404:
            print("❌ Endpoint not found")
            throw URLError(.badURL)
        default:
            print("❌ Unexpected status code: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
    }
    
    func syncOrderedSessionDrills(sessionDrills: [EditableDrillModel]) async throws {
        let url = URL(string: "\(baseURL)/api/sessions/ordered_drills/")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using auth token: \(token)")
        } else {
            print("⚠️ No auth token found!")
        }
        
        // Convert drills to dictionary format
        let drillsData = sessionDrills.map { drill in
            return [
                "drill": [
                    "id": drill.drill.id.uuidString,
                    "backend_id": drill.drill.backendId as Any,
                    "title": drill.drill.title,
                    "skill": drill.drill.skill,
                    "sets": drill.totalSets,
                    "reps": drill.totalReps,
                    "duration": drill.totalDuration,
                    "description": drill.drill.description,
                    "tips": drill.drill.tips,
                    "equipment": drill.drill.equipment,
                    "training_style": drill.drill.trainingStyle,
                    "difficulty": drill.drill.difficulty
                ],
                "sets_done": drill.setsDone,
                "total_sets": drill.totalSets,
                "total_reps": drill.totalReps,
                "total_duration": drill.totalDuration,
                "is_completed": drill.isCompleted
            ]
        }
        
        let requestData = ["ordered_drills": drillsData]
        
        print("📤 Sending request to: \(url.absoluteString)")
        print("Request headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Request body: \(requestData)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw URLError(.badServerResponse)
            }
            
            print("📥 Response status code: \(httpResponse.statusCode)")
            print("📥 Response headers: \(httpResponse.allHeaderFields)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                print("✅ Successfully synced ordered session drills")
            case 401:
                print("❌ Unauthorized - Invalid or expired token")
                print("🔑 Current token: \(KeychainWrapper.standard.string(forKey: "authToken") ?? "no token")")
                throw URLError(.userAuthenticationRequired)
            case 404:
                print("❌ Endpoint not found - Check API route: \(url.absoluteString)")
                throw URLError(.badURL)
            case 422:
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ Validation error: \(responseString)")
                }
                throw URLError(.badServerResponse)
            default:
                print("❌ Unexpected status code: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
                throw URLError(.badServerResponse)
            }
        } catch {
            print("❌ Error during request: \(error)")
            throw error
        }
    }
    
    
    // MARK: - Progress History Sync
    
    struct ProgressHistoryResponse: Codable {
        let currentStreak: Int
        let highestStreak: Int
        let completedSessionsCount: Int
    }
    
    func fetchProgressHistory() async throws -> ProgressHistoryResponse {
        let url = URL(string: "\(baseURL)/api/progress_history/")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using auth token: \(token)")
        } else {
            print("⚠️ No auth token found!")
            throw URLError(.userAuthenticationRequired)
        }
        
        print("📤 Fetching progress history from: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw URLError(.badServerResponse)
        }
        
        print("📥 Response status code: \(httpResponse.statusCode)")
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let progressHistory = try decoder.decode(ProgressHistoryResponse.self, from: data)
            print("✅ Successfully fetched progress history")
            return progressHistory
        case 401:
            print("❌ Unauthorized - Invalid or expired token")
            throw URLError(.userAuthenticationRequired)
        case 404:
            print("❌ Endpoint not found")
            throw URLError(.badURL)
        default:
            print("❌ Unexpected status code: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
    }

    func syncProgressHistory(currentStreak: Int, highestStreak: Int, completedSessionsCount: Int) async throws {
        let url = URL(string: "\(baseURL)/api/progress_history/")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using auth token: \(token)")
        } else {
            print("⚠️ No auth token found!")
        }
        
        // Create a mutable dictionary to build our progress history
        let progressHistory: [String: Any] = [
            "current_streak": currentStreak,
            "highest_streak": highestStreak,
            "completed_sessions_count": completedSessionsCount
        ]
        
        print("📤 Sending request to: \(url.absoluteString)")
        print("Request headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Request body: \(progressHistory)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: progressHistory)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw URLError(.badServerResponse)
            }
            
            print("📥 Response status code: \(httpResponse.statusCode)")
            print("📥 Response headers: \(httpResponse.allHeaderFields)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                print("✅ Successfully synced progress history")
            case 401:
                print("❌ Unauthorized - Invalid or expired token")
                print("🔑 Current token: \(KeychainWrapper.standard.string(forKey: "authToken") ?? "no token")")
                throw URLError(.userAuthenticationRequired)
            case 404:
                print("❌ Endpoint not found - Check API route: \(url.absoluteString)")
                throw URLError(.badURL)
            case 422:
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ Validation error: \(responseString)")
                }
                throw URLError(.badServerResponse)
            default:
                print("❌ Unexpected status code: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
                throw URLError(.badServerResponse)
            }
        } catch {
            print("❌ Error during request: \(error)")
            throw error
        }
    }
    
    // MARK: - Completed Sessions Sync
    
    func fetchCompletedSessions() async throws -> [CompletedSession] {
        let url = URL(string: "\(baseURL)/api/sessions/completed/")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using auth token: \(token)")
        } else {
            print("⚠️ No auth token found!")
            throw URLError(.userAuthenticationRequired)
        }
        
        print("📤 Fetching completed sessions from: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw URLError(.badServerResponse)
        }
        
        print("📥 Response status code: \(httpResponse.statusCode)")
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let completedSessions = try decoder.decode([CompletedSession].self, from: data)
            print("✅ Successfully fetched \(completedSessions.count) completed sessions")
            return completedSessions
        case 401:
            print("❌ Unauthorized - Invalid or expired token")
            throw URLError(.userAuthenticationRequired)
        case 404:
            print("❌ Endpoint not found")
            throw URLError(.badURL)
        default:
            print("❌ Unexpected status code: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
    }

    func syncCompletedSession(date: Date, drills: [EditableDrillModel], totalCompleted: Int, total: Int) async throws {
        let url = URL(string: "\(baseURL)/api/sessions/completed/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Convert drills to dictionary format
        let drillsData = drills.map { drill in
            return [
                "drill": [
                    "id": drill.drill.id.uuidString,
                    "title": drill.drill.title,
                    "skill": drill.drill.skill,
                    "sets": drill.totalSets,
                    "reps": drill.totalReps,
                    "duration": drill.totalDuration,
                    "description": drill.drill.description,
                    "tips": drill.drill.tips,
                    "equipment": drill.drill.equipment,
                    "trainingStyle": drill.drill.trainingStyle,
                    "difficulty": drill.drill.difficulty
                ],
                "setsDone": drill.setsDone,
                "totalSets": drill.totalSets,
                "totalReps": drill.totalReps,
                "totalDuration": drill.totalDuration,
                "isCompleted": drill.isCompleted
            ]
        }
        
        let sessionData = [
            "date": ISO8601DateFormatter().string(from: date),
            "drills": drillsData,
            "total_completed_drills": totalCompleted,
            "total_drills": total
        ] as [String : Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: sessionData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("📥 Backend response status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response: \(responseString)")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        print("✅ Successfully synced completed session")
    }
    
    // MARK: - Drill Groups Sync
    
    func syncAllDrillGroups(savedGroups: [GroupModel], likedGroup: GroupModel) async throws {
        print("\n🔄 Syncing all drill groups...")
        
        // First, sync liked group
        try await syncLikedGroup(likedGroup)
        
        // Then sync all saved groups
        for group in savedGroups {
            try await syncSavedGroup(group)
        }
        
        print("✅ Successfully synced all drill groups")
    }

    private func syncLikedGroup(_ group: GroupModel) async throws {
        print("🔄 Syncing liked group...")
        
        // Extract backend IDs from drills
        let drillIds = group.drills.compactMap { $0.backendId }
        
        // Get or create liked group
        let likedGroup = try await DrillGroupService.shared.getLikedDrillsGroup()
        
        // Update liked group with current drills
        _ = try await DrillGroupService.shared.updateDrillGroupWithIds(
            groupId: likedGroup.id,
            name: group.name,
            description: group.description,
            drillIds: drillIds,
            isLikedGroup: true
        )
        
        print("✅ Successfully synced liked group")
    }

    private func syncSavedGroup(_ group: GroupModel) async throws {
        print("🔄 Syncing group: \(group.name)...")
        
        // Extract backend IDs from drills
        let drillIds = group.drills.compactMap { $0.backendId }
        
        // Get all existing groups
        let existingGroups = try await DrillGroupService.shared.getAllDrillGroups()
        
        // Try to find matching group
        if let existingGroup = existingGroups.first(where: { $0.name == group.name && !$0.isLikedGroup }) {
            // Update existing group
            _ = try await DrillGroupService.shared.updateDrillGroupWithIds(
                groupId: existingGroup.id,
                name: group.name,
                description: group.description,
                drillIds: drillIds,
                isLikedGroup: false
            )
        } else {
            // Create new group
            _ = try await DrillGroupService.shared.createDrillGroupWithIds(
                name: group.name,
                description: group.description,
                drillIds: drillIds,
                isLikedGroup: false
            )
        }
        
        print("✅ Successfully synced group: \(group.name)")
    }

    // TODO: might want to remove this and just do drillResponse object
    // Add a helper class for creating DrillResponse objects
    private struct MockDrillResponse: Codable {
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
        let sets: Int?
        let reps: Int?
        let rest: Int?
        
        // Convert to a DrillResponse
        func toDrillResponse() -> DrillResponse {
            return DrillResponse(
                id: self.id,
                title: self.title,
                description: self.description,
                duration: self.duration,
                intensity: self.intensity,
                difficulty: self.difficulty,
                equipment: self.equipment,
                suitableLocations: self.suitableLocations,
                instructions: self.instructions,
                tips: self.tips,
                type: self.type,
                sets: self.sets,
                reps: self.reps,
                rest: self.rest
            )
        }
    }
} 
