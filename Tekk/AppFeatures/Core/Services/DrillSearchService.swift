//
//  DrillSearchService.swift
//  BravoBall
//
//  Created by Jordan on 3/17/25.
//

import Foundation
import SwiftKeychainWrapper

// Response model for search results with pagination
struct DrillSearchResponse: Decodable {
    let items: [DrillResponse]?
    let total: Int
    let page: Int
    let pageSize: Int
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case items, total, page
        case pageSize = "page_size"
        case totalPages = "total_pages"
    }
}

class DrillSearchService {
    static let shared = DrillSearchService()
    private let baseURL = AppSettings.baseURL
    
    private init() {}
    
    // Helper method to get auth token
    private func getAuthToken() -> String? {
        return KeychainWrapper.standard.string(forKey: "authToken")
    }
    
    /// Search for drills with various filter options
    func searchDrills(
        query: String = "",
        category: String? = nil,
        difficulty: String? = nil,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> DrillSearchResponse {
        guard let token = getAuthToken() else {
            throw NSError(domain: "DrillSearchService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authentication token not found"])
        }
        
        // Check if we're trying to load all drills
        let isInitialLoad = query.isEmpty && category == nil && difficulty == nil
        
        // Build URL with query parameters
        var urlComponents = URLComponents(string: "\(baseURL)/api/drills/search")
        var queryItems = [URLQueryItem(name: "query", value: query)]
        
        // Add optional parameters if they exist
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        if let difficulty = difficulty {
            queryItems.append(URLQueryItem(name: "difficulty", value: difficulty))
        }
        
        // Add pagination parameters
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        
        // Use a larger limit when loading all drills
        if isInitialLoad {
            // Request more drills when showing all
            queryItems.append(URLQueryItem(name: "limit", value: "100"))
        } else {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw NSError(domain: "DrillSearchService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🔍 Searching drills with URL: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "DrillSearchService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
//        // For debugging - print the response
//        if let responseString = String(data: data, encoding: .utf8) {
//            print("📥 Search API Response: \(responseString)")
//        }
        
        if httpResponse.statusCode == 200 {
            print("✅ Successfully retrieved drill search results")
            
            // Try to manually parse the response first to handle null values properly
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let items = json["items"] as? [[String: Any]] {
                
                print("✅ Manually processing \(items.count) items from JSON")
                
                // Create DrillResponse objects from raw JSON with null safety
                var drillResponses: [DrillResponse] = []
                
                for item in items {
                    do {
                        let id = item["id"] as? Int ?? 0
                        let title = item["title"] as? String ?? "Unnamed Drill"
                        let description = item["description"] as? String ?? ""
                        
                        // Handle potentially null numeric values
                        let duration: Int
                        if let durationValue = item["duration"] as? Int {
                            duration = durationValue
                        } else {
                            duration = 10 // Default value
                        }
                        
                        let intensity = item["intensity"] as? String ?? "medium"
                        let difficulty = item["difficulty"] as? String ?? "beginner"
                        
                        // Handle array fields safely
                        let equipment = item["equipment"] as? [String] ?? []
                        let suitableLocations = item["suitable_locations"] as? [String] ?? []
                        let instructions = item["instructions"] as? [String] ?? []
                        let tips = item["tips"] as? [String] ?? []
                        
                        let type = item["type"] as? String ?? "other"
                                                
                        // Handle nullable integers
                        let sets: Int? = item["sets"] as? Int
                        let reps: Int? = item["reps"] as? Int
                        let rest: Int? = item["rest"] as? Int
                        
                        // Handle primary skill
                        var primarySkill: DrillResponse.Skill? = nil
                        if let primarySkillData = item["primary_skill"] as? [String: Any] {
                            primarySkill = DrillResponse.Skill(
                                category: primarySkillData["category"] as? String ?? "",
                                subSkill: primarySkillData["sub_skill"] as? String ?? ""
                            )
                        }
                        
                        // Handle secondary skills
                        var secondarySkills: [DrillResponse.Skill] = []
                        if let secondarySkillsData = item["secondary_skills"] as? [[String: Any]] {
                            secondarySkills = secondarySkillsData.map { skillData in
                                DrillResponse.Skill(
                                    category: skillData["category"] as? String ?? "",
                                    subSkill: skillData["sub_skill"] as? String ?? ""
                                )
                            }
                        }
                        
                        let videoURL = item["video_url"] as? String ?? ""
                        
                        
                        
                        let drillResponse = DrillResponse(
                            id: id,
                            title: title,
                            description: description,
                            duration: duration,
                            intensity: intensity,
                            difficulty: difficulty,
                            equipment: equipment,
                            suitableLocations: suitableLocations,
                            instructions: instructions,
                            tips: tips,
                            type: type,
                            sets: sets,
                            reps: reps,
                            rest: rest,
                            primarySkill: primarySkill,
                            secondarySkills: secondarySkills,
                            videoURL: videoURL
                        )
                        
                        drillResponses.append(drillResponse)
                        
                        // Debug print for the first few drills
                        if drillResponses.count <= 3 {
                            print("\nProcessed Drill \(drillResponses.count):")
                            print("- Title:", drillResponse.title)
                            print("- Primary Skill:", drillResponse.primarySkill?.category ?? "None")
                            print("- Primary SubSkill:", drillResponse.primarySkill?.subSkill ?? "None")
                            print("- Type:", drillResponse.type)
                            print("- Secondary Skills:", drillResponse.secondarySkills?.map { "\($0.category):\($0.subSkill)" } ?? [])
                        }
                    } catch {
                        print("⚠️ Error processing drill item:", error)
                        continue
                    }
                }
                
                // If we successfully processed at least one drill, return the result
                if !drillResponses.isEmpty {
                    return DrillSearchResponse(
                        items: drillResponses,
                        total: json["total"] as? Int ?? drillResponses.count,
                        page: json["page"] as? Int ?? page,
                        pageSize: json["page_size"] as? Int ?? limit,
                        totalPages: json["total_pages"] as? Int ?? 1
                    )
                }
            }
            
            // If manual parsing fails, try the standard decoder with error handling
            do {
                let decoder = JSONDecoder()
                // Configure decoder to be more lenient
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN")
                
                let response = try decoder.decode(DrillSearchResponse.self, from: data)
                
                // If items is nil, create a response with empty items
                if response.items == nil {
                    print("⚠️ Items field was nil in response, using mock data temporarily")
                    return createMockSearchResponse(page: page, limit: limit)
                }
                
                // If items is empty but we're doing an initial load, use mock data
                if isInitialLoad && (response.items?.isEmpty ?? true) {
                    print("⚠️ Initial load returned empty items, using mock data temporarily")
                    return createMockSearchResponse(page: page, limit: limit)
                }
                
                return response
            } catch {
                print("❌ JSON Decoding error: \(error)")
                
                // Try to create a fallback response with mock data
                if isInitialLoad {
                    print("⚠️ Using mock data after decoding failure")
                    return createMockSearchResponse(page: page, limit: limit)
                }
                
                // Try to parse as a simple JSON object in case the structure is different
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("📊 Raw JSON response: \(json)")
                    
                    // Try to manually extract data if JSON structure doesn't match our model
                    if let items = json["items"] as? [[String: Any]] {
                        print("✅ Manually extracted \(items.count) items from JSON")
                        
                        // Create DrillResponse objects from raw JSON
                        var drillResponses: [DrillResponse] = []
                        
                        for item in items {
                            if let id = item["id"] as? Int,
                               let title = item["title"] as? String {
                                let description = item["description"] as? String ?? ""
                                let duration = item["duration"] as? Int ?? 10
                                let intensity = item["intensity"] as? String ?? "medium"
                                let difficulty = item["difficulty"] as? String ?? "beginner"
                                let equipment = item["equipment"] as? [String] ?? []
                                let suitableLocations = item["suitable_locations"] as? [String] ?? []
                                let instructions = item["instructions"] as? [String] ?? []
                                let tips = item["tips"] as? [String] ?? []
                                let type = item["type"] as? String ?? "passing"
                                                                
                                let sets = item["sets"] as? Int
                                let reps = item["reps"] as? Int
                                let rest = item["rest"] as? Int
                                
                                let primarySkill = item["primary_skill"] as? DrillResponse.Skill
                                let secondarySkills = item["secondary_skills"] as? [DrillResponse.Skill]
                                
                                let videoURL = item["video_url"] as? String ?? ""
                                
                                
                                
                                let drillResponse = DrillResponse(
                                    id: id,
                                    title: title,
                                    description: description,
                                    duration: duration,
                                    intensity: intensity,
                                    difficulty: difficulty,
                                    equipment: equipment,
                                    suitableLocations: suitableLocations,
                                    instructions: instructions,
                                    tips: tips,
                                    type: type,
                                    sets: sets,
                                    reps: reps,
                                    rest: rest,
                                    primarySkill: primarySkill,
                                    secondarySkills: secondarySkills,
                                    videoURL: videoURL
                                )
                                
                                drillResponses.append(drillResponse)
                            }
                        }
                        
                        return DrillSearchResponse(
                            items: drillResponses,
                            total: json["total"] as? Int ?? drillResponses.count,
                            page: json["page"] as? Int ?? page,
                            pageSize: json["page_size"] as? Int ?? limit,
                            totalPages: json["total_pages"] as? Int ?? 1
                        )
                    }
                }
                
                // If all else fails, return an empty response
                return DrillSearchResponse(
                    items: [],
                    total: 0,
                    page: page,
                    pageSize: limit,
                    totalPages: 0
                )
            }
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            let errorMessage = errorResponse?.detail ?? "Failed to search drills"
            print("❌ Search error: \(errorMessage)")
            
            // If it's an initial load and we get an error, return mock data
            if isInitialLoad {
                print("⚠️ Error on initial load, using mock data temporarily")
                return createMockSearchResponse(page: page, limit: limit)
            }
            
            throw NSError(domain: "DrillSearchService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
    }
    
    /// Create mock search response for testing
    private func createMockSearchResponse(page: Int, limit: Int) -> DrillSearchResponse {
        let mockDrills: [DrillResponse] = [
            DrillResponse(
                id: 1,
                title: "One-Touch Pass",
                description: "A passing drill that improves first-touch control and quick decision-making using the wall",
                duration: 15,
                intensity: "medium",
                difficulty: "beginner",
                equipment: ["ball", "wall"],
                suitableLocations: ["full_field", "medium_field", "indoor_court", "backyard"],
                instructions: ["Stand 5 yards away from a wall with the ball.", "Pass the ball against the wall and immediately pass it back in one touch."],
                tips: ["Keep your ankle locked for better pass accuracy.", "Stay on your toes to react quickly to the return pass."],
                type: "passing",
                sets: 3,
                reps: 30,
                rest: 30,
                primarySkill: DrillResponse.Skill(category: "passing", subSkill: "short_passing"),
                secondarySkills: [
                    DrillResponse.Skill(category: "passing", subSkill: "first_touch"),
                    DrillResponse.Skill(category: "passing", subSkill: "ball_control")
                ],
                videoURL: ""
            ),
            DrillResponse(
                id: 2,
                title: "Cone Dribbling",
                description: "Improve close control dribbling through a series of cones",
                duration: 20,
                intensity: "medium",
                difficulty: "beginner",
                equipment: ["ball", "cones"],
                suitableLocations: ["full_field", "medium_field", "indoor_court", "backyard"],
                instructions: ["Set up 6 cones in a zig-zag pattern.", "Dribble through the cones as quickly as possible while maintaining control."],
                tips: ["Use both feet", "Keep the ball close to your feet", "Look up occasionally"],
                type: "dribbling",
                sets: 4,
                reps: 5,
                rest: 45,
                primarySkill: DrillResponse.Skill(category: "passing", subSkill: "short_passing"),
                secondarySkills: [
                    DrillResponse.Skill(category: "passing", subSkill: "first_touch"),
                    DrillResponse.Skill(category: "passing", subSkill: "ball_control")
                ],
                videoURL: ""
            ),
            DrillResponse(
                id: 3,
                title: "Shooting Practice",
                description: "Basic shooting drill to improve accuracy and power",
                duration: 25,
                intensity: "high",
                difficulty: "intermediate",
                equipment: ["ball", "goal"],
                suitableLocations: ["full_field", "medium_field"],
                instructions: ["Place the ball 15 yards from goal", "Take a shot aiming for the corners"],
                tips: ["Plant your non-kicking foot beside the ball", "Follow through with your shot", "Keep your head down"],
                type: "shooting",
                sets: 3,
                reps: 10,
                rest: 60,
                primarySkill: DrillResponse.Skill(category: "passing", subSkill: "short_passing"),
                secondarySkills: [
                    DrillResponse.Skill(category: "passing", subSkill: "first_touch"),
                    DrillResponse.Skill(category: "passing", subSkill: "ball_control")
                ],
                videoURL: ""
            ),
            DrillResponse(
                id: 4,
                title: "Defensive Shuffle",
                description: "Improve defensive footwork and positioning",
                duration: 15,
                intensity: "high",
                difficulty: "intermediate",
                equipment: ["cones"],
                suitableLocations: ["full_field", "medium_field", "indoor_court"],
                instructions: ["Set up cones in a 10x10 yard square", "Shuffle between cones in defensive stance"],
                tips: ["Stay low", "Keep your feet shoulder-width apart", "Quick, short steps"],
                type: "defending",
                sets: 4,
                reps: 8,
                rest: 45,
                primarySkill: DrillResponse.Skill(category: "passing", subSkill: "short_passing"),
                secondarySkills: [
                    DrillResponse.Skill(category: "passing", subSkill: "first_touch"),
                    DrillResponse.Skill(category: "passing", subSkill: "ball_control")
                ],
                videoURL: ""
            ),
            DrillResponse(
                id: 5,
                title: "Juggling Challenge",
                description: "Improve ball control and first touch",
                duration: 10,
                intensity: "low",
                difficulty: "beginner",
                equipment: ["ball"],
                suitableLocations: ["full_field", "medium_field", "indoor_court", "backyard", "small_room"],
                instructions: ["Start with the ball in your hands", "Drop and juggle the ball with your feet", "Try to reach your target number without letting the ball touch the ground"],
                tips: ["Use the laces area of your foot", "Keep your ankle locked", "Stay balanced"],
                type: "first_touch",
                sets: 5,
                reps: 20,
                rest: 30,
                primarySkill: DrillResponse.Skill(category: "passing", subSkill: "short_passing"),
                secondarySkills: [
                    DrillResponse.Skill(category: "passing", subSkill: "first_touch"),
                    DrillResponse.Skill(category: "passing", subSkill: "ball_control")
                ],
                videoURL: ""
            )
        ]
        
        return DrillSearchResponse(
            items: page == 1 ? mockDrills : [],
            total: mockDrills.count,
            page: page,
            pageSize: limit,
            totalPages: 1
        )
    }
    
    /// Convert DrillResponse objects to local DrillModel objects
    func convertToLocalModels(drillResponses: [DrillResponse]?) -> [DrillModel] {
        guard let drillResponses = drillResponses else {
            return []
        }
        
        return drillResponses.map { response in
            let drillModel = response.toDrillModel()
            // Create a new drill model with the backend ID included
            return DrillModel(
                id: drillModel.id,
                backendId: response.id,
                title: drillModel.title,
                skill: drillModel.skill,
                subSkills: drillModel.subSkills,
                sets: drillModel.sets,
                reps: drillModel.reps,
                duration: drillModel.duration,
                description: drillModel.description,
                instructions: drillModel.instructions,
                tips: drillModel.tips,
                equipment: drillModel.equipment,
                trainingStyle: drillModel.trainingStyle,
                difficulty: drillModel.difficulty,
                videoURL: response.videoURL
            )
        }
    }
}

// Simple error response struct for decoding API errors
private struct ErrorResponse: Decodable {
    let detail: String
}
