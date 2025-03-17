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
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var authToken: String = ""
    @Published var isLoggedIn: Bool = false
    
    private let keychain = KeychainWrapper.standard
    
    init() {
        loadUserData()
    }
    
    // Updates the currentUser instance of User structure
    func updateUserKeychain(email: String, firstName: String, lastName: String) {
        
        // Store in Keychain
        keychain.set(email, forKey: "userEmail")
        keychain.set(firstName, forKey: "userFirstName")
        keychain.set(lastName, forKey: "userLastName")
        
        print("✅ User data saved to Keychain")
        print("Email: \(email)")
        print("First Name: \(firstName)")
        print("Last Name: \(lastName)")
    }
    
    func clearUserKeychain() {
        // Clear Keychain
        keychain.removeObject(forKey: "userEmail")
        keychain.removeObject(forKey: "userFirstName")
        keychain.removeObject(forKey: "userLastName")
        
        
        print("✅ User data cleared from Keychain")
    }
    
    // Returns tuple of user info from () -> its types, must be in same order
    func getUserFromKeychain() -> (email: String, firstName: String, lastName: String) {
        let email = KeychainWrapper.standard.string(forKey: "userEmail") ?? ""
        let firstName = KeychainWrapper.standard.string(forKey: "userFirstName") ?? ""
        let lastName = KeychainWrapper.standard.string(forKey: "userLastName") ?? ""
        
        return (email, firstName, lastName)
        
    }
    
    func saveUserData() {
        // Save user data to UserDefaults
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(firstName, forKey: "firstName")
        UserDefaults.standard.set(lastName, forKey: "lastName")
        UserDefaults.standard.set(email, forKey: "email")
        
        // Save auth token to Keychain for better security
        KeychainWrapper.standard.set(authToken, forKey: "authToken")
        
        // Update login state
        isLoggedIn = !authToken.isEmpty
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
    }
    
    func loadUserData() {
        // Load user data from UserDefaults
        userId = UserDefaults.standard.integer(forKey: "userId")
        firstName = UserDefaults.standard.string(forKey: "firstName") ?? ""
        lastName = UserDefaults.standard.string(forKey: "lastName") ?? ""
        email = UserDefaults.standard.string(forKey: "email") ?? ""
        
        // Load auth token from Keychain
        authToken = KeychainWrapper.standard.string(forKey: "authToken") ?? ""
        
        // Update login state
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    func logout() {
        // Clear user data
        userId = 0
        firstName = ""
        lastName = ""
        email = ""
        authToken = ""
        isLoggedIn = false
        
        // Remove from UserDefaults and Keychain
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "firstName")
        UserDefaults.standard.removeObject(forKey: "lastName")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        KeychainWrapper.standard.removeObject(forKey: "authToken")
    }
}
