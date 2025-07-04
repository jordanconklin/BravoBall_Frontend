//
//  OnboardingModelTest.swift
//  BravoBall
//
//  Created by Jordan on 1/6/25.
//

import Foundation
import SwiftKeychainWrapper

class OnboardingModel: ObservableObject {
    let globalSettings = GlobalSettings()

    @Published var currentStep = 0
    // For question transition when back button pressed
    @Published var backTransition: Bool = false
    @Published var onboardingData = OnboardingData()
    
    @Published var showLoginPage = false
    @Published var showWelcome = false
    @Published var showIntroAnimation = true
    @Published var isLoggedIn = false
    @Published var accessToken = ""
    @Published var isPasswordVisible: Bool = false
    @Published var numberOfOnboardingPages = 8 // Updated to include registration page and preview page
    
    // TESTING: Set this to true to skip onboarding and go straight to completion
    @Published var skipOnboarding = false
    
    // Variables for when onboarding data is being submitted
    @Published var isLoading = true
    @Published var errorMessage: String = ""
    
    // Animation scale for intro animation
    @Published var animationScale: CGFloat = 1.5

    // Indicates if the user has completed onboarding and entered the main app
    @Published var onboardingComplete: Bool = false
    
    // Simple arrays for questions and options
    let questionTitles = [
        "What is your primary soccer goal?",
        "How much training experience do you have?",
        "What position do you play?",
        "What age range do you fall under?",
        "What are your strengths?",
        "What would you like to work on?"
    ]
    
    let questionOptions = [
        ["Improve my overall skill level", "Be the best player on my team", "Get scouted for college",
         "Become a professional footballer", "Have fun and enjoy the game"],
        ["Beginner", "Intermediate", "Advanced", "Professional"],
        ["Goalkeeper", "Fullback", "Center-back", "Defensive Midfielder", "Center Midfielder",
         "Attacking Midfielder", "Winger", "Striker"],
        ["Under 12", "13–16", "17–19", "20–29", "30+"],
        ["Passing", "Dribbling", "Shooting", "First touch"],
        ["Passing", "Dribbling", "Shooting", "First touch"]
    ]
    
    // Onboarding data answers from the user
    struct OnboardingData: Codable {
        var primaryGoal: String = ""
        var trainingExperience: String = ""
        var position: String = ""
        var ageRange: String = ""
        var strengths: [String] = []
        var areasToImprove: [String] = []
        var email: String = ""
        var password: String = ""
        var confirmPassword: String = ""
        
        // Keep these for future use but they won't be used in the current flow
        var biggestChallenge: [String] = []
        var playstyle: [String] = []
        var trainingLocation: [String] = []
        var availableEquipment: [String] = []
        var dailyTrainingTime: String = ""
        var weeklyTrainingDays: String = ""
    }

    @Published var showForgotPasswordPage: Bool = false
    @Published var forgotPasswordMessage: String = ""
    @Published var forgotPasswordStep: Int = 1 // 1: email, 2: code, 3: new password
    @Published var forgotPasswordEmail: String = ""
    @Published var forgotPasswordCode: String = ""
    @Published var forgotPasswordNewPassword: String = ""
    @Published var forgotPasswordConfirmPassword: String = ""
    @Published var isNewPasswordVisible: Bool = false

    init() {
        // Check for existing authentication on init
        restoreLoginStateFromStorage()
    }

    // Checks if youre allowed to move to next question (validates data)
    func canMoveNext() -> Bool {
        switch currentStep {
        case 0: return true
        case 1: return !onboardingData.primaryGoal.isEmpty
        case 2: return !onboardingData.trainingExperience.isEmpty
        case 3: return !onboardingData.position.isEmpty
        case 4: return !onboardingData.ageRange.isEmpty
        case 5: return !onboardingData.strengths.isEmpty
        case 6: return !onboardingData.areasToImprove.isEmpty
        case 7: return !onboardingData.email.isEmpty && !onboardingData.password.isEmpty && !onboardingData.confirmPassword.isEmpty
        default: return false
        }
    }
    
    //MARK: Global functions
    
    // Attempts to the next question
    func moveNext() {
        if canMoveNext() && currentStep < numberOfOnboardingPages {
            currentStep += 1
        }
    }
    
    // Attempts to skip to the next question
    func skipToNext() {
        if currentStep < numberOfOnboardingPages {
            currentStep += 1
        }
    }
    
    // Attempts to move back through back button
    func movePrevious() {
        if currentStep > 0 {
            currentStep -= 1
        } else if currentStep == 0 {
            // Return to welcome screen
            showWelcome = false
        }
    }
    
    func resetOnboardingData() {
        // Reset all published properties for onboarding
        currentStep = 0
        showLoginPage = false
        showWelcome = false
        showIntroAnimation = false // TESTING: set to true after
        accessToken = ""
        
        // Reset onboardingData to default values
        onboardingData = OnboardingData()  // This creates a new instance with default values
        
        // Debug print
        print("OnboardingModel reset completed")
        print("onb email: \(onboardingData.email)")
        print("Current step: \(currentStep)")
        print("auth token nil value: \(accessToken)")
    }

    // TESTING: Method to prefill onboarding data for testing
    func prefillTestData() {
        // Generate a random email to avoid duplicates
        let randomInt = (Int.random(in: 100...9999))
        let randomEmail = "test\(randomInt)@example.com"
        
        // Use values that exactly match the questionOptions arrays
        onboardingData = OnboardingData(
            primaryGoal: "Improve my overall skill level",
            trainingExperience: "Intermediate",
            position: "Goalkeeper",
            ageRange: "Teen (13-16)",
            strengths: ["Defending"],
            areasToImprove: ["Passing", "Dribbling", "First touch"],
            email: randomEmail,
            password: "123"
        )
        
        print("✅ Test data prefilled with email: \(randomEmail)")
    }

    // MARK: - Validation
    var registrationValidationError: String? {
        if onboardingData.email.isEmpty { return "Email is required." }
        if !AccountValidation.isValidEmail(onboardingData.email) { return "Please enter a valid email address." }
        if onboardingData.password.isEmpty { return "Password is required." }
        if let passError = AccountValidation.passwordError(onboardingData.password) { return passError }
        if onboardingData.confirmPassword.isEmpty { return "Please confirm your password." }
        if onboardingData.password != onboardingData.confirmPassword { return "Passwords do not match." }
        return nil
    }

    // MARK: - Persistent Login State Management
    
    /// Restores login state from stored tokens in Keychain
    func restoreLoginStateFromStorage() {
        let storedAccessToken = KeychainWrapper.standard.string(forKey: "accessToken") ?? ""
        let storedUserEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? ""
        
        // User is logged in if they have both access token and email
        if !storedAccessToken.isEmpty && !storedUserEmail.isEmpty {
            accessToken = storedAccessToken
            isLoggedIn = true
            print("🔑 Restored login state from storage - User: \(storedUserEmail)")
        } else {
            print("📱 No stored authentication found")
        }
    }
    
    /// Clears login state and stored tokens
    func clearLoginState() {
        isLoggedIn = false
        accessToken = ""
        showLoginPage = false
        showWelcome = false
        showIntroAnimation = false
        
        // Clear stored tokens
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "refreshToken")
        KeychainWrapper.standard.removeObject(forKey: "userEmail")
        
        print("🧹 Cleared login state and stored tokens")
    }

    // MARK: - Forgot Password Logic
    func checkEmailExists(email: String) async -> Bool {
        do {
            let jsonBody = try JSONSerialization.data(withJSONObject: ["email": email])
            let (data, response) = try await APIService.shared.request(
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
    
    func sendForgotPassword(email: String) async {
        DispatchQueue.main.async {
            self.forgotPasswordMessage = ""
        }
        
        // First check if email exists
        let emailExists = await checkEmailExists(email: email)
        if !emailExists {
            DispatchQueue.main.async {
                self.forgotPasswordMessage = "Email not found. Please check your email address."
            }
            return
        }
        
        do {
            let (data, response) = try await APIService.shared.forgotPassword(email: email)
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.forgotPasswordEmail = email
                    self.forgotPasswordStep = 2
                    self.forgotPasswordMessage = "Verification code sent to your email."
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
                DispatchQueue.main.async {
                    self.forgotPasswordMessage = "Failed to send code: \(responseString)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.forgotPasswordMessage = "Network error. Please try again."
            }
        }
    }
    
    func verifyResetCode(code: String) async {
        DispatchQueue.main.async {
            self.forgotPasswordMessage = ""
        }
        do {
            let (data, response) = try await APIService.shared.verifyResetCode(email: forgotPasswordEmail, code: code)
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.forgotPasswordCode = code
                    self.forgotPasswordStep = 3
                    self.forgotPasswordMessage = "Code verified successfully."
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Invalid code"
                DispatchQueue.main.async {
                    self.forgotPasswordMessage = "Invalid or expired code. Please try again."
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.forgotPasswordMessage = "Network error. Please try again."
            }
        }
    }
    
    func resetPassword(newPassword: String, confirmPassword: String) async {
        DispatchQueue.main.async {
            self.forgotPasswordMessage = ""
        }
        
        // Validate passwords
        if newPassword != confirmPassword {
            DispatchQueue.main.async {
                self.forgotPasswordMessage = "Passwords do not match."
            }
            return
        }
        
        if let passwordError = AccountValidation.passwordError(newPassword) {
            DispatchQueue.main.async {
                self.forgotPasswordMessage = passwordError
            }
            return
        }
        
        do {
            let (data, response) = try await APIService.shared.resetPassword(
                email: forgotPasswordEmail,
                code: forgotPasswordCode,
                newPassword: newPassword
            )
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.forgotPasswordMessage = "Password reset successfully!"
                    // Reset all forgot password state
                    self.resetForgotPasswordState()
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
                DispatchQueue.main.async {
                    self.forgotPasswordMessage = "Failed to reset password: \(responseString)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.forgotPasswordMessage = "Network error. Please try again."
            }
        }
    }
    
    func resetForgotPasswordState() {
        forgotPasswordStep = 1
        forgotPasswordEmail = ""
        forgotPasswordCode = ""
        forgotPasswordNewPassword = ""
        forgotPasswordConfirmPassword = ""
        forgotPasswordMessage = ""
        showForgotPasswordPage = false
    }
}
