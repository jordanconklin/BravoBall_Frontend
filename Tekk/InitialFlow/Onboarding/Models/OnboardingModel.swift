//
//  OnboardingModelTest.swift
//  BravoBall
//
//  Created by Jordan on 1/6/25.
//

import Foundation
import SwiftKeychainWrapper

class OnboardingModel: ObservableObject {
    let globalSettings = GlobalSettings.shared

    @Published var currentStep = 0
    // For question transition when back button pressed
    @Published var backTransition: Bool = false
    @Published var onboardingData = OnboardingData()
    

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
    func movePrevious(userManager: UserManager) {
        if currentStep > 0 {
            currentStep -= 1
        } else if currentStep == 0 {
            // Return to welcome screen
            userManager.showWelcome = false
        }
    }
    
    func resetOnboardingData() {
        currentStep = 0
//        showIntroAnimation = false
        
        // Reset onboardingData to default values
        onboardingData = OnboardingData()  // This creates a new instance with default values
        
        // Debug print
        print("OnboardingModel reset completed")
        print("onb email: \(onboardingData.email)")
        print("Current step: \(currentStep)")

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


}
