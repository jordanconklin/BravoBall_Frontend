//
//  LoginResponse.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/2/25.
//

// expected response structure from backend after POST request to login endpoint
struct LoginResponse: Codable {
    let access_token: String
    let token_type: String
    let email: String
    let refresh_token: String?
}
