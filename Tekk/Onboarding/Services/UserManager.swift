//
//  UserManager.swift
//  BravoBall
//
//  Created by Joshua Conklin on 3/10/25.
//

import Foundation
import SwiftUI
import SwiftKeychainWrapper


class UserManager: ObservableObject {
    @Published var userId: Int = 0
    @Published var email: String = ""
    @Published var accessToken: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var userHasAccountHistory: Bool = false
    
    private let keychain = KeychainWrapper.standard
    
    init() {
        loadUserData()
    }
    
    // Updates the currentUser instance of User structure
    func updateUserKeychain(email: String) {
        
        // Store in Keychain
        keychain.set(email, forKey: "userEmail")
        
        print("✅ User data saved to Keychain")
        print("Email: \(email)")
    }
    
    func clearUserKeychain() {
        // Clear Keychain
        keychain.removeObject(forKey: "userEmail")
        
        print("✅ User data cleared from Keychain")
    }
    
    // Returns tuple of user info from () -> its types, must be in same order
    func getUserFromKeychain() -> String {
        let email = KeychainWrapper.standard.string(forKey: "userEmail") ?? ""
        return email
    }
    
    func saveUserData() {
        // Save user data to UserDefaults
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(email, forKey: "email")
        
        // Save access token to Keychain for better security
        KeychainWrapper.standard.set(accessToken, forKey: "accessToken")
        
        // Update login state
        isLoggedIn = !accessToken.isEmpty
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
    }
    
    func loadUserData() {
        // Load user data from UserDefaults
        userId = UserDefaults.standard.integer(forKey: "userId")
        email = UserDefaults.standard.string(forKey: "email") ?? ""
        
        // Load access token from Keychain
        accessToken = KeychainWrapper.standard.string(forKey: "accessToken") ?? ""
        
        // Also load email from keychain (this is the primary source)
        let keychainEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? ""
        if !keychainEmail.isEmpty {
            email = keychainEmail
        }
        
        // Update login state - user is logged in if they have both email and access token
        isLoggedIn = !accessToken.isEmpty && !email.isEmpty
        userHasAccountHistory = isLoggedIn
        
        // Update UserDefaults to reflect current state
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        
        print("📱 UserManager loaded data - Email: \(email), isLoggedIn: \(isLoggedIn)")
    }
    
    func logout() {
        print("\n👋 User logging out...")
        
        // Store previous email for logging purposes
        let previousEmail = email
        
        // Clear user data
        userId = 0
        email = ""
        accessToken = ""
        isLoggedIn = false
        userHasAccountHistory = false
        
        // Remove from UserDefaults and Keychain
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "refreshToken")
        KeychainWrapper.standard.removeObject(forKey: "userEmail")
        
        // Clear user-specific liked drills UUID
        UserDefaults.standard.removeObject(forKey: "\(previousEmail)_likedDrillsUUID")
        
        // Clear user cache to ensure all data is properly removed
        CacheManager.shared.clearUserCache()
        
        // Reset last active user to force clearing in next initialization
        UserDefaults.standard.removeObject(forKey: "lastActiveUser")
        
        // Post a notification that user has logged out so all views can update
        NotificationCenter.default.post(
            name: Notification.Name("UserLoggedOut"),
            object: nil,
            userInfo: ["previousEmail": previousEmail]
        )
        
        print("✅ User data cleared from all storage")
    }
}
