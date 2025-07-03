//
//  OnboardingResponse.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/3/25.
//

// Define the structure for the onboarding response
struct OnboardingResponse: Codable {
    let status: String
    let message: String
    let access_token: String
    let refresh_token: String?
    let tokenType: String
    let userId: Int
    let initialSession: SessionResponse?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case access_token
        case refresh_token
        case tokenType = "token_type"
        case userId = "user_id"
        case initialSession = "initial_session"
    }
}
