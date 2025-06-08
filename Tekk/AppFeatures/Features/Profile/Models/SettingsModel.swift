//
//  SettingsModel.swift
//  BravoBall
//
//  Created by Jordan on 3/28/25.
//

import SwiftUI
import SwiftKeychainWrapper

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
    
    func updateUserDetails(email: String) async throws {
        let endpoint = "/api/user/update"
        let bodyDict: [String: Any] = [
            "email": email
        ]
        let body = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let (_, response) = try await APIService.shared.request(
            endpoint: endpoint,
            method: "PUT",
            headers: ["Content-Type": "application/json"],
            body: body
        )
        
        guard response.statusCode == 200 else {
            throw NSError(domain: "", code: response.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to update user details"])
        }
        
        // Update UI on the main thread
        await MainActor.run {
            // Update local storage
            self.email = email
            // Update UserDefaults
            UserDefaults.standard.set(email, forKey: "email")
        }
    }
}

struct SocialLink: Identifiable {
    let id = UUID()
    let platform: String
    let url: String
    let icon: String
}
