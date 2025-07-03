//
//  SettingsModel.swift
//  BravoBall
//
//  Created by Jordan on 3/28/25.
//

import SwiftUI
import SwiftKeychainWrapper


// TODO: separate service components



class SettingsModel: ObservableObject {
    @Published var email: String {
        didSet { UserDefaults.standard.set(email, forKey: "email") }
    }
    
    let socialLinks = [
        SocialLink(platform: "TikTok", url: "https://www.tiktok.com/@conklinofficial", icon: "tiktok.icon"),
        SocialLink(platform: "Instagram", url: "https://www.instagram.com/conklinofficial/", icon: "instagram.icon"),
        SocialLink(platform: "YouTube", url: "https://www.youtube.com/channel/UC-5hKmXbLicdUuV0e3Bk1AQ", icon: "youtube.icon")
    ]
    
    init() {
        // Try to get user data from KeychainWrapper first
        if let userData = KeychainWrapper.standard.string(forKey: "userEmail") {
            self.email = userData
        } else {
            // Fallback to UserDefaults if not found in Keychain
            self.email = UserDefaults.standard.string(forKey: "email") ?? ""
        }
    }
    
    func updateUserEmail(email: String) async throws {
        // Only proceed if the new email is different from the current one
        guard email != self.email else {
            print("📧 Email unchanged, no update needed")
            return
        }
        
        let endpoint = "/api/user/update-email"
        let bodyDict: [String: Any] = [
            "email": email
        ]
        
        let body = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let (_, response) = try await APIService.shared.request(
            endpoint: endpoint,
            method: "PUT",
            headers: ["Content-Type": "application/json"],
            body: body,
            debounceKey: "update_email",
            debounceInterval: 1.0
        )
        
        guard response.statusCode == 200 else {
            throw NSError(domain: "", code: response.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to update email"])
        }
        
        // Update UI on the main thread
        await MainActor.run {
            // Update local storage
            self.email = email
            // Update UserDefaults
            UserDefaults.standard.set(email, forKey: "email")
        }
    }
    
    func updateUserPassword(currentPassword: String, newPassword: String) async throws {
        let endpoint = "/api/user/update-password"
        let bodyDict: [String: Any] = [
            "current_password": currentPassword,
            "new_password": newPassword
        ]
        
        let body = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let (_, response) = try await APIService.shared.request(
            endpoint: endpoint,
            method: "PUT",
            headers: ["Content-Type": "application/json"],
            body: body,
            debounceKey: "update_password",
            debounceInterval: 1.0
        )
        
        guard response.statusCode == 200 else {
            throw NSError(domain: "", code: response.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to update password"])
        }
    }
}

struct SocialLink: Identifiable {
    let id = UUID()
    let platform: String
    let url: String
    let icon: String
}
