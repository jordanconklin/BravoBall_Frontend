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
        let (data, response) = try await APIService.shared.requestFullURL(
            url: url,
            method: "GET",
            headers: ["Content-Type": "application/json"]
        )
        guard response.statusCode == 200 else {
            print("❌ Invalid response type")
            throw URLError(.badServerResponse)
        }
        print("📥 Response status code: \(response.statusCode)")
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
    }
    
    func syncOrderedSessionDrills(sessionDrills: [EditableDrillModel], sessionId: Int) async throws {
        let url = URL(string: "\(baseURL)/api/sessions/ordered_drills/")!
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
                "sets": drill.totalSets,
                "reps": drill.totalReps,
                "duration": drill.totalDuration,
                "is_completed": drill.isCompleted,
                "session_id": sessionId
            ]
        }
        let requestData = ["ordered_drills": drillsData]
        let body = try JSONSerialization.data(withJSONObject: requestData)
        let (data, response) = try await APIService.shared.requestFullURL(
            url: url,
            method: "PUT",
            headers: ["Content-Type": "application/json"],
            body: body
        )
        guard response.statusCode == 200 else {
            print("❌ Unexpected status code: \(response.statusCode)")
            throw URLError(.badServerResponse)
        }
        print("✅ Successfully synced ordered session drills")
    }
    
    
    // MARK: - Progress History Sync
    
    struct ProgressHistoryResponse: Codable {
        let currentStreak: Int
        let highestStreak: Int
        let completedSessionsCount: Int
    }
    
    func fetchProgressHistory() async throws -> ProgressHistoryResponse {
        let url = URL(string: "\(baseURL)/api/progress_history/")!
        let (data, response) = try await APIService.shared.requestFullURL(
            url: url,
            method: "GET",
            headers: ["Content-Type": "application/json"]
        )
        guard response.statusCode == 200 else {
            print("❌ Invalid response type")
            throw URLError(.badServerResponse)
        }
        print("📥 Response status code: \(response.statusCode)")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let progressHistory = try decoder.decode(ProgressHistoryResponse.self, from: data)
        print("✅ Successfully fetched progress history")
        return progressHistory
    }

    func syncProgressHistory(currentStreak: Int, highestStreak: Int, completedSessionsCount: Int) async throws {
        let url = URL(string: "\(baseURL)/api/progress_history/")!
        let progressHistory: [String: Any] = [
            "current_streak": currentStreak,
            "highest_streak": highestStreak,
            "completed_sessions_count": completedSessionsCount
        ]
        let body = try JSONSerialization.data(withJSONObject: progressHistory)
        let (data, response) = try await APIService.shared.requestFullURL(
            url: url,
            method: "PUT",
            headers: ["Content-Type": "application/json"],
            body: body
        )
        guard response.statusCode == 200 else {
            print("❌ Unexpected status code: \(response.statusCode)")
            throw URLError(.badServerResponse)
        }
        print("✅ Successfully synced progress history")
    }
    
    // MARK: - Completed Sessions Sync
    
    func fetchCompletedSessions() async throws -> [CompletedSession] {
        let url = URL(string: "\(baseURL)/api/sessions/completed/")!
        let (data, response) = try await APIService.shared.requestFullURL(
            url: url,
            method: "GET",
            headers: ["Content-Type": "application/json"]
        )
        guard response.statusCode == 200 else {
            print("❌ Invalid response type")
            throw URLError(.badServerResponse)
        }
        print("📥 Response status code: \(response.statusCode)")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let completedSessions = try decoder.decode([CompletedSession].self, from: data)
        print("✅ Successfully fetched \(completedSessions.count) completed sessions")
        return completedSessions
    }

    func syncCompletedSession(date: Date, drills: [EditableDrillModel], totalCompleted: Int, total: Int) async throws {
        let url = URL(string: "\(baseURL)/api/sessions/completed/")!
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
        let body = try JSONSerialization.data(withJSONObject: sessionData)
        let (data, response) = try await APIService.shared.requestFullURL(
            url: url,
            method: "POST",
            headers: ["Content-Type": "application/json"],
            body: body
        )
        guard response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        print("✅ Successfully synced completed session")
    }
    
    // MARK: - Drill Groups Sync
    
    func syncAllDrillGroups(savedGroups: [GroupModel], likedGroup: GroupModel) async throws {
        print("\n🔄 Syncing all drill groups...")
        
        // First, get all existing groups in one call
        let existingGroups = try await DrillGroupService.shared.getAllDrillGroups()
        print("📥 Fetched \(existingGroups.count) existing groups")
        
        // Prepare liked group sync
        let likedDrillIds = likedGroup.drills.compactMap { $0.backendId }
        if let existingLikedGroup = existingGroups.first(where: { $0.isLikedGroup }) {
            // Only update if there are differences
            if Set(existingLikedGroup.drills.map { $0.id }) != Set(likedDrillIds) {
                try await DrillGroupService.shared.updateDrillGroupWithIds(
                    groupId: existingLikedGroup.id,
                    name: likedGroup.name,
                    description: likedGroup.description,
                    drillIds: likedDrillIds,
                    isLikedGroup: true
                )
                print("✅ Updated liked group")
            } else {
                print("✓ Liked group is up to date")
            }
        }
        
        // Prepare saved groups sync
        for group in savedGroups {
            let drillIds = group.drills.compactMap { $0.backendId }
            
            // Try to find matching existing group
            if let existingGroup = existingGroups.first(where: { $0.name == group.name && !$0.isLikedGroup }) {
                // Only update if there are differences
                if Set(existingGroup.drills.map { $0.id }) != Set(drillIds) {
                    try await DrillGroupService.shared.updateDrillGroupWithIds(
                        groupId: existingGroup.id,
                        name: group.name,
                        description: group.description,
                        drillIds: drillIds,
                        isLikedGroup: false
                    )
                    print("✅ Updated group: \(group.name)")
                } else {
                    print("✓ Group \(group.name) is up to date")
                }
            } else {
                // Create new group
                _ = try await DrillGroupService.shared.createDrillGroupWithIds(
                    name: group.name,
                    description: group.description,
                    drillIds: drillIds,
                    isLikedGroup: false
                )
                print("✅ Created new group: \(group.name)")
            }
        }
        
        print("✅ Successfully synced all drill groups")
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
        let subSkills: [String]
        let sets: Int?
        let reps: Int?
        let rest: Int?
        let primarySkill: DrillResponse.Skill?
        let secondarySkills: [DrillResponse.Skill]?
        let videoUrl: String
        
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
                rest: self.rest,
                primarySkill: self.primarySkill,
                secondarySkills: self.secondarySkills,
                videoUrl: self.videoUrl
            )
        }
    }
}
