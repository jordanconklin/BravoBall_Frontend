//
//  AuthenticationService.swift
//  BravoBall
//
//  Created by Assistant on 1/15/25.
//

import Foundation
import SwiftKeychainWrapper

final class AuthenticationService: ObservableObject, AuthenticationManaging {
    static let shared = AuthenticationService()
    
    @Published private(set) var isCheckingAuthentication = false
    @Published private(set) var isAuthenticated = false
    
    // Add loading state for authentication check
    @Published private(set) var isCheckingAuth = true
    
    private init() {}
    
    /// Checks if user has valid stored credentials and validates them with the backend
    func checkAuthenticationStatus() async -> Bool {
        print("🔍 AuthenticationService: Starting authentication check...")
        
        await MainActor.run {
            isCheckingAuthentication = true
        }
        
        // Check if we have stored tokens
        guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken"),
              let userEmail = KeychainWrapper.standard.string(forKey: "userEmail"),
              !accessToken.isEmpty,
              !userEmail.isEmpty else {
            print("❌ AuthenticationService: No stored tokens found")
            await MainActor.run {
                isCheckingAuthentication = false
                isAuthenticated = false
            }
            return false
        }
        
        print("✅ AuthenticationService: Found stored tokens for user: \(userEmail)")
        print("🔑 AuthenticationService: Access token: \(accessToken.prefix(20))...")
        
        // Validate token with backend
        do {
            print("🌐 AuthenticationService: Validating token with backend...")
            let (_, response) = try await APIService.shared.request(
                endpoint: "/api/session/preferences",
                method: "GET",
                headers: ["Content-Type": "application/json"],
                retryOn401: false,
                debounceKey: "auth_check",
                debounceInterval: 0.5
            )
            
            let isValid = response.statusCode == 200
            print("🌐 AuthenticationService: Backend response status: \(response.statusCode)")
            
            await MainActor.run {
                isCheckingAuthentication = false
                isAuthenticated = isValid
            }
            
            if isValid {
                print("✅ AuthenticationService: Token validation successful")
            } else {
                print("❌ AuthenticationService: Token validation failed")
            }
            
            return isValid
            
        } catch {
            print("❌ AuthenticationService: Error validating token: \(error.localizedDescription)")
            // If validation fails, clear invalid tokens
            await clearInvalidTokens()
            
            await MainActor.run {
                isCheckingAuthentication = false
                isAuthenticated = false
            }
            
            return false
        }
    }
    
    // MARK: - Authentication Check
    
    func updateAuthenticationStatus(onboardingModel: OnboardingModel, userManager: UserManager) async {
        print("\n🔐 ===== STARTING AUTHENTICATION CHECK =====")
        print("📅 Timestamp: \(Date())")
        
        // Check if user has valid stored credentials
        let isAuthenticated = await checkAuthenticationStatus()
        
        // Add a minimum delay to show the loading animation
        try? await Task.sleep(nanoseconds: 00_800_000_000) // 0.8 second delay
        
        await MainActor.run {
            if isAuthenticated {
                // User has valid tokens, restore login state
                print("✅ Authentication check passed - restoring login state")
                
                // Restore user data from keychain
                let userEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? ""
                let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") ?? ""
                
                print("📱 Restoring data - Email: \(userEmail)")
                print("🔑 Restoring data - Access Token: \(accessToken.prefix(20))...")
                
                // Update user manager
                userManager.email = userEmail
                userManager.accessToken = accessToken
                userManager.isLoggedIn = true
                userManager.userHasAccountHistory = true
                
                // Update onboarding model
                onboardingModel.accessToken = accessToken
                onboardingModel.isLoggedIn = true
                
                print("🔑 Restored login state for user: \(userEmail)")
            } else {
                print("❌ Authentication check failed - user needs to login")
                print("📱 No valid tokens found or backend validation failed")
            }
            
            // End loading state
            isCheckingAuth = false
            print("🏁 Authentication check complete - isCheckingAuth: \(isCheckingAuth)")
        }
    }
    
    /// Clears invalid tokens from Keychain
    func clearInvalidTokens() async {
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "refreshToken")
        KeychainWrapper.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "lastActiveUser")
    }
}
