//
//  APIService.swift
//  BravoBall
//
//  Created by Jordan on 6/4/25.
//

import Foundation
import SwiftKeychainWrapper

struct TokenResponse: Codable {
    let access_token: String
    let refresh_token: String
    let token_type: String
}

class APIService {
    static let shared = APIService()
    private let baseURL = AppSettings.baseURL
    
    private var accessToken: String? {
        KeychainWrapper.standard.string(forKey: "accessToken")
    }
    private var refreshToken: String? {
        KeychainWrapper.standard.string(forKey: "refreshToken")
    }
    
    // Generic request function
    func request(
        endpoint: String,
        method: String = "GET",
        headers: [String: String]? = nil,
        body: Data? = nil,
        retryOn401: Bool = true,
        debounceKey: String? = nil,
        debounceInterval: TimeInterval? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        // Check if we should debounce this request
        if let debounceKey = debounceKey,
           !DebounceService.shared.shouldProceedWithRequest(key: debounceKey, interval: debounceInterval) {
            throw URLError(.timedOut)
        }
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        if let accessToken = accessToken {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        if let headers = headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        urlRequest.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // Handle 401 Unauthorized (try refresh logic)
        if httpResponse.statusCode == 401 && retryOn401, let refreshToken = refreshToken {
            print("🔄 Access token expired, attempting refresh...")
            try await refreshAccessToken(refreshToken: refreshToken)
            // Retry the original request once
            return try await request(
                endpoint: endpoint,
                method: method,
                headers: headers,
                body: body,
                retryOn401: false,
                debounceKey: debounceKey,
                debounceInterval: debounceInterval
            )
        }
        return (data, httpResponse)
    }
    
    // Refresh token logic
    func refreshAccessToken(refreshToken: String) async throws {
        guard let url = URL(string: baseURL + "/refresh/") else { throw URLError(.badURL) }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["refresh_token": refreshToken]
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            // Refresh failed, log out
//            logout()
            throw URLError(.userAuthenticationRequired)
        }
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        // Save new tokens
        KeychainWrapper.standard.set(tokenResponse.access_token, forKey: "accessToken")
        KeychainWrapper.standard.set(tokenResponse.refresh_token, forKey: "refreshToken")
    }

    // Helper for decoding JSON
    func decodeResponse<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
} 
