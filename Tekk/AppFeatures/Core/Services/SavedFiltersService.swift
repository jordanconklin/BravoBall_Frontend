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
        
        // Create new filters
        let url = URL(string: "\(baseURL)/api/filters/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
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
        request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
        
        print("📤 Sending \(newFilters.count) new filters")
        print("📤 Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Print response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response body: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            switch httpResponse.statusCode {
            case 200:
                print("✅ Successfully synced \(newFilters.count) new filters")
            case 500:
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ Server error: \(responseString)")
                }
                throw URLError(.badServerResponse)
            default:
                print("❌ Unexpected status code: \(httpResponse.statusCode)")
                throw URLError(.badServerResponse)
            }
        } catch {
            print("❌ Error syncing filters: \(error)")
            throw error
        }
    }

    // Add the fetch function to get all saved filters from the backend
    func fetchSavedFilters() async throws -> [SavedFiltersModel] {
        let url = URL(string: "\(baseURL)/api/filters/")!
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
        
        print("📤 Fetching saved filters from: \(url.absoluteString)")
        
        do {
            // Send the request and get the response
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check the response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw URLError(.badServerResponse)
            }
            
            print("📥 Response status code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response body: \(responseString)")
            }
            
            // Handle the response
            switch httpResponse.statusCode {
            case 200:
                
                let decoder = JSONDecoder()
                let filters = try decoder.decode([SavedFiltersModel].self, from: data)
                
                // Convert backend response to our model
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
                print("❌ Unexpected status code: \(httpResponse.statusCode)")
                throw URLError(.badServerResponse)
            }
        } catch {
            print("❌ Error fetching saved filters: \(error)")
            throw error
        }
    }
    
    // TODO: add delete method
}

