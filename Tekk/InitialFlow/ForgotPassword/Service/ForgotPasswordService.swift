//
//  ForgotPasswordService.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/2/25.
//

import SwiftUI

class ForgotPasswordService {
    static let shared = ForgotPasswordService()
    
    func checkEmailExists(email: String, forgotPasswordModel: ForgotPasswordModel) async -> Bool {
        do {
            let jsonBody = try JSONSerialization.data(withJSONObject: ["email": email])
            let (_, response) = try await APIService.shared.request(
                endpoint: "/check-existing-email/",
                method: "POST",
                headers: ["Content-Type": "application/json"],
                body: jsonBody
            )
            return response.statusCode == 200
        } catch {
            return false
        }
    }
    
    @MainActor
    func sendForgotPassword(email: String, forgotPasswordModel: ForgotPasswordModel) async {
        forgotPasswordModel.forgotPasswordMessage = ""
        
        // First check if email exists
        let emailExists = await checkEmailExists(email: email, forgotPasswordModel: forgotPasswordModel)
        if !emailExists {
                forgotPasswordModel.forgotPasswordMessage = "Email not found. Please check your email address."
            return
        }
        
        do {
            let (data, response) = try await APIService.shared.forgotPassword(email: email)
            if response.statusCode == 200 {
                forgotPasswordModel.forgotPasswordEmail = email
                forgotPasswordModel.forgotPasswordStep = 2
                forgotPasswordModel.forgotPasswordMessage = "Verification code sent to your email."
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
                    forgotPasswordModel.forgotPasswordMessage = "Failed to send code: \(responseString)"
            }
        } catch {
            forgotPasswordModel.forgotPasswordMessage = "Network error. Please try again."
        }
    }
    
    @MainActor
    func verifyResetCode(code: String, forgotPasswordModel: ForgotPasswordModel) async {
            forgotPasswordModel.forgotPasswordMessage = ""
        do {
            let (data, response) = try await APIService.shared.verifyResetCode(email: forgotPasswordModel.forgotPasswordEmail, code: code)
            if response.statusCode == 200 {
                forgotPasswordModel.forgotPasswordCode = code
                forgotPasswordModel.forgotPasswordStep = 3
                forgotPasswordModel.forgotPasswordMessage = "Code verified successfully."
            } else {
                let _ = String(data: data, encoding: .utf8) ?? "Invalid code"
                    forgotPasswordModel.forgotPasswordMessage = "Invalid or expired code. Please try again."
            }
        } catch {
            forgotPasswordModel.forgotPasswordMessage = "Network error. Please try again."
        }
    }
    
    @MainActor
    func resetPassword(newPassword: String, confirmPassword: String, forgotPasswordModel: ForgotPasswordModel) async {
        forgotPasswordModel.forgotPasswordMessage = ""
        
        // Validate passwords
        if newPassword != confirmPassword {
                forgotPasswordModel.forgotPasswordMessage = "Passwords do not match."
            return
        }
        
        if let passwordError = AccountValidation.passwordError(newPassword) {
            forgotPasswordModel.forgotPasswordMessage = passwordError
            return
        }
        
        do {
            let (data, response) = try await APIService.shared.resetPassword(
                email: forgotPasswordModel.forgotPasswordEmail,
                code: forgotPasswordModel.forgotPasswordCode,
                newPassword: newPassword
            )
            if response.statusCode == 200 {
                forgotPasswordModel.forgotPasswordMessage = "Password reset successfully!"
                    // Reset all forgot password state
                forgotPasswordModel.resetForgotPasswordState()
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
                forgotPasswordModel.forgotPasswordMessage = "Failed to reset password: \(responseString)"
            }
        } catch {
            forgotPasswordModel.forgotPasswordMessage = "Network error. Please try again."
        }
    }
}


