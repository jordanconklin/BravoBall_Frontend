//
//  AuthenticationService.swift
//  BravoBall
//
//  Created by Assistant on 1/15/25.
//

import Foundation
import SwiftKeychainWrapper

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var isCheckingAuthentication = false
    @Published var isAuthenticated = false
    
    private init() {}
    
    /// Checks if user has valid stored credentials and validates them with the backend
    func checkAuthenticationStatus() async -> Bool {
        await MainActor.run {
            isCheckingAuthentication = true
        }
        
        // Check if we have stored tokens
        guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken"),
              let userEmail = KeychainWrapper.standard.string(forKey: "userEmail"),
              !accessToken.isEmpty,
              !userEmail.isEmpty else {
            await MainActor.run {
                isCheckingAuthentication = false
                isAuthenticated = false
            }
            return false
        }
        
        // Validate token with backend
        do {
            let (_, response) = try await APIService.shared.request(
                endpoint: "/api/session/preferences",
                method: "GET",
                headers: ["Content-Type": "application/json"],
                retryOn401: false,
                debounceKey: "auth_check",
                debounceInterval: 0.5
            )
            
            let isValid = response.statusCode == 200
            
            await MainActor.run {
                isCheckingAuthentication = false
                isAuthenticated = isValid
            }
            
            return isValid
            
        } catch {
            // If validation fails, clear invalid tokens
            await clearInvalidTokens()
            
            await MainActor.run {
                isCheckingAuthentication = false
                isAuthenticated = false
            }
            
            return false
        }
    }
    
    /// Clears invalid tokens from Keychain
    private func clearInvalidTokens() async {
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "refreshToken")
        KeychainWrapper.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "lastActiveUser")
    }
}
