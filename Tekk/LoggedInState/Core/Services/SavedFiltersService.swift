//
//  SavedFiltersService.swift
//  BravoBall
//
//  Created by Joshua Conklin on 3/26/25.
//

import Foundation
import SwiftKeychainWrapper

class SavedFiltersService {
    static let shared = SavedFiltersService()
    private let baseURL = AppSettings.baseURL
    
    func syncSavedFilters(savedFilters: [SavedFiltersModel]) async throws {
        print("\n🔄 Syncing saved filters...")
        
        // First fetch existing filters
        let existingFilters = try await fetchSavedFilters()
        
        // Find only new filters that don't exist in the backend
        let newFilters = savedFilters.filter { filter in
            !existingFilters.contains { $0.id == filter.id }
        }
        
        // If no new filters, we're done
        if newFilters.isEmpty {
            print("✓ No new filters to sync")
            return
        }
        
        print("📝 Found \(newFilters.count) new filters to sync")
        
        // Convert only new filters to match backend's expected format
        let filterObjects = newFilters.map { filter -> [String: Any?] in
            [
                "id": filter.id.uuidString,
                "name": filter.name,
                "saved_time": filter.savedTime,
                "saved_equipment": Array(filter.savedEquipment),
                "saved_training_style": filter.savedTrainingStyle,
                "saved_location": filter.savedLocation,
                "saved_difficulty": filter.savedDifficulty
            ]
        }
        
        // Create the request body structure
        let requestData = [
            "saved_filters": filterObjects
        ]
        
        // Convert to JSON data
        let body = try JSONSerialization.data(withJSONObject: requestData)
        
        print("📤 Sending \(newFilters.count) new filters")
        print("📤 Request body: \(String(data: body, encoding: .utf8) ?? "")")
        
        let endpoint = "/api/filters/"
        let (data, response) = try await APIService.shared.request(
            endpoint: endpoint,
            method: "POST",
            headers: ["Content-Type": "application/json"],
            body: body
        )
        
        // Print response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response body: \(responseString)")
        }
        
        switch response.statusCode {
        case 200:
            print("✅ Successfully synced \(newFilters.count) new filters")
        case 500:
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ Server error: \(responseString)")
            }
            throw URLError(.badServerResponse)
        default:
            print("❌ Unexpected status code: \(response.statusCode)")
            throw URLError(.badServerResponse)
        }
    }

    func fetchSavedFilters() async throws -> [SavedFiltersModel] {
        let endpoint = "/api/filters/"
        let (data, response) = try await APIService.shared.request(
            endpoint: endpoint,
            method: "GET",
            headers: ["Content-Type": "application/json"]
        )
        
        print("📥 Response status code: \(response.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response body: \(responseString)")
        }
        
        // Handle the response
        switch response.statusCode {
        case 200:
            let decoder = JSONDecoder()
            let filters = try decoder.decode([SavedFiltersModel].self, from: data)
            
            // Convert backend response to our SavedFiltersModel
            return filters.map { response in
                SavedFiltersModel(
                    id: response.id,
                    backendId: response.backendId,
                    name: response.name,
                    savedTime: response.savedTime,
                    savedEquipment: Set(response.savedEquipment),
                    savedTrainingStyle: response.savedTrainingStyle,
                    savedLocation: response.savedLocation,
                    savedDifficulty: response.savedDifficulty
                )
            }
            
        case 401:
            print("❌ Unauthorized - Invalid or expired token")
            throw URLError(.userAuthenticationRequired)
        case 404:
            print("❌ Endpoint not found")
            throw URLError(.badURL)
        default:
            print("❌ Unexpected status code: \(response.statusCode)")
            throw URLError(.badServerResponse)
        }
    }
    
    // TODO: add delete method
}

