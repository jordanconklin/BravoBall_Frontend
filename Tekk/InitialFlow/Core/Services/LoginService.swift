//
//  LoginService.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/2/25.
//
import SwiftUI
import SwiftKeychainWrapper

class LoginService {
    static let shared = LoginService()
    
    @MainActor
    func loginUser(userManager: UserManager, loginModel: LoginModel) async {
        guard !loginModel.email.isEmpty, !loginModel.password.isEmpty else {
            loginModel.errorMessage = "Please fill in all fields."
            return
        }

        Task {
            let loginDetails = [
                "email": loginModel.email,
                "password": loginModel.password
            ]
            let body = try? JSONSerialization.data(withJSONObject: loginDetails)
            do {
                let (data, response) = try await APIService.shared.request(
                    endpoint: "/login/",
                    method: "POST",
                    headers: ["Content-Type": "application/json"],
                    body: body,
                    retryOn401: false,
                    debounceKey: "login_request",
                    debounceInterval: 1.0
                )
                if response.statusCode == 200 {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                        userManager.accessToken = loginResponse.access_token
                        KeychainWrapper.standard.set(loginResponse.access_token, forKey: "accessToken")
                        if let refreshToken = loginResponse.refresh_token {
                            KeychainWrapper.standard.set(refreshToken, forKey: "refreshToken")
                        }
                        // Save user info to Keychain (only email now)
                        userManager.updateUserKeychain(
                            email: loginResponse.email
                        )
                        userManager.userHasAccountHistory = true
                        userManager.isLoggedIn = true
                        userManager.showLoginPage = false
                        loginModel.resetLoginInfo()
                        print("🔑 Token saved to keychain: \(KeychainWrapper.standard.string(forKey: "accessToken") ?? "nil")")
                        print("🔑 Refresh token saved to keychain: \(KeychainWrapper.standard.string(forKey: "refreshToken") ?? "nil")")
                        print("Auth token: \(userManager.accessToken)")
                        print("Login success: \(userManager.isLoggedIn)")
                } else if response.statusCode == 401 {
                    loginModel.errorMessage = "Invalid credentials, please try again."
                    print("❌ Login failed: Invalid credentials")
                } else {
                    loginModel.errorMessage = "Failed to login. Please try again."
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response data not fully completed: \(responseString)")
                    }
                }
            } catch URLError.timedOut {
                print("⏱️ Login request debounced - too soon since last request")
            } catch {
                loginModel.errorMessage = "Network error. Please try again."
                print("Login error: \(error.localizedDescription)")
            }
        }
    }
}
