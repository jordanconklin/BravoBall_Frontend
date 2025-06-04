//
//  OnboardingModelTest.swift
//  BravoBall
//
//  Created by Jordan on 1/6/25.
//

import Foundation

class OnboardingModel: ObservableObject {
    let globalSettings = GlobalSettings()

    @Published var currentStep = 0
    // For question transition when back button pressed
    @Published var backTransition: Bool = false
    @Published var onboardingData = OnboardingData()
    
    @Published var showLoginPage = false
    @Published var showWelcome = false
    @Published var showIntroAnimation = true // TESTING, toggle when need to
    @Published var isLoggedIn = false
    @Published var accessToken = ""
    @Published var isPasswordVisible: Bool = false
    @Published var numberOfOnboardingPages = 14 // Updated to include registration page and preview page
    
    // TESTING: Set this to true to skip onboarding and go straight to completion
    @Published var skipOnboarding = true
    
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
        "What are your biggest challenges to achieving this goal?",
        "How much individual training experience do you have?",
        "What position do you play?",
        "Which players best describes your playstyle?",
        "What age range do you fall under?",
        "What are your strengths?",
        "What would you like to work on?",
        "Where do you typically train?",
        "What equipment do you have available?",
        "How much time do you have to train daily?",
        "How many days per week do you want to train?"
    ]
    
    let questionOptions = [
        ["Improve my overall skill level", "Be the best player on my team", "Get scouted for college",
         "Become a professional footballer", "Have fun and enjoy the game"],
        ["Lack of time", "Lack of proper training equipment", "Not knowing what to work on",
         "Staying motivated", "Recovering from injury", "No team or structured training", "Lack of confidence"],
        ["Beginner", "Intermediate", "Advanced", "Professional"],
        ["Goalkeeper", "Fullback", "Center-back", "Defensive Midfielder", "Center Midfielder",
         "Attacking Midfielder", "Winger", "Striker"],
        ["Lionel Messi", "Cristiano Ronaldo", "Neymar Jr", "Jamal Musiala", "Eden Hazard", "Reece James", "William Saliba", "Marta", "Karim Benzema", "Jules Kounde", "Kevin De Bruyne", "Christian Pulisic", "Busquets", "Harry Maguire", "Casemiro", "Bukayo Saka", "Sergio Ramos", "Manuel Neuer", "Alex Balde", "Mo Salah", "Alex Morgan", "Dani Alves", "Aitana Bonmati", "Mesut Ozil", "Jordi Alba", "Joshua Kimmich", "Lamine Yamal", "Antonee Robinson", "Puyol", "Modric", "David Silva", "Rodri", "Bruno Fernandes", "Vivianne Meidema", "Kylian Mbappe", "Xavi", "Allison", "Ngolo Kante", "Harry Kane", "Sergio Aguero", "Erling Haaland", "Gareth Bale", "Thierry Henry", "Thibaut Courtois", "Vinicius Jr", "Iniesta"],
        ["Youth (Under 12)", "Teen (13-16)", "Junior (17-19)", "Adult (20-29)", "Senior (30+)"],
        ["Passing", "Dribbling", "Shooting", "First touch"],
        ["Passing", "Dribbling", "Shooting", "First touch"],
        ["At a soccer field with goals", "At home (backyard or indoors)", "At a park or open field",
         "At a gym or indoor court"],
        ["Soccer ball", "Cones", "Wall", "Goals"],
        ["Less than 15 minutes", "15-30 minutes", "30-60 minutes", "1-2 hours", "More than 2 hours"],
        ["2-3 days (light schedule)", "4-5 days (moderate schedule)", "6-7 days (intense schedule)"]
    ]
    
    // Onboarding data answers from the user
    struct OnboardingData: Codable {
        var primaryGoal: String = ""
        var biggestChallenge: [String] = []
        var trainingExperience: String = ""
        var position: String = ""
        var playstyle: [String] = []
        var ageRange: String = ""
        var strengths: [String] = []
        var areasToImprove: [String] = []
        var trainingLocation: [String] = []
        var availableEquipment: [String] = []
        var dailyTrainingTime: String = ""
        var weeklyTrainingDays: String = ""
        var firstName: String = ""
        var lastName: String = ""
        var email: String = ""
        var password: String = ""
    }

    // Checks if youre allowed to move to next question (validates data)
    func canMoveNext() -> Bool {
        switch currentStep {
        case 0: return true
        case 1: return !onboardingData.primaryGoal.isEmpty
        case 2: return !onboardingData.biggestChallenge.isEmpty
        case 3: return !onboardingData.trainingExperience.isEmpty
        case 4: return !onboardingData.position.isEmpty
        case 5: return !onboardingData.playstyle.isEmpty
        case 6: return !onboardingData.ageRange.isEmpty
        case 7: return !onboardingData.strengths.isEmpty
        case 8: return !onboardingData.areasToImprove.isEmpty
        case 9: return !onboardingData.trainingLocation.isEmpty
        case 10: return !onboardingData.availableEquipment.isEmpty
        case 11: return !onboardingData.dailyTrainingTime.isEmpty
        case 12: return !onboardingData.weeklyTrainingDays.isEmpty
        case 13: return !onboardingData.firstName.isEmpty &&
                        !onboardingData.lastName.isEmpty &&
                        !onboardingData.email.isEmpty &&
                        !onboardingData.password.isEmpty
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
        print("onb first name: \(onboardingData.firstName)")
        print("onb last name: \(onboardingData.lastName)")
        print("onb email: \(onboardingData.email)")
        print("password: \(onboardingData.password)")
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
            biggestChallenge: ["Not enough time to train"],
            trainingExperience: "Intermediate",
            position: "Goalkeeper",
            playstyle: ["Big Bob"],  // Match one of the actual options in questionOptions
            ageRange: "Teen (13-16)",
            strengths: ["Defending"],
            areasToImprove: ["Passing", "Dribbling", "First touch"],
            trainingLocation: ["Full-sized field"],  // Match one of the actual options
            availableEquipment: ["Soccer ball", "Cones", "Wall"],
            dailyTrainingTime: "15-30 minutes",
            weeklyTrainingDays: "3-5 days (moderate schedule)",
            firstName: "Test",
            lastName: "User\(randomInt)",  // Random last name to avoid duplicates
            email: randomEmail,
            password: "123"
        )
        
        print("✅ Test data prefilled with email: \(randomEmail)")
        print("✅ Primary goal: \(onboardingData.primaryGoal)")
        print("✅ Biggest challenge: \(onboardingData.biggestChallenge)")
        print("✅ Training experience: \(onboardingData.trainingExperience)")
        print("✅ Position: \(onboardingData.position)")
        print("✅ Playstyle: \(onboardingData.playstyle)")
        print("✅ Age range: \(onboardingData.ageRange)")
        print("✅ Strengths: \(onboardingData.strengths)")
        print("✅ Areas to improve: \(onboardingData.areasToImprove)")
        print("✅ Training location: \(onboardingData.trainingLocation)")
        print("✅ Available equipment: \(onboardingData.availableEquipment)")
        print("✅ Daily training time: \(onboardingData.dailyTrainingTime)")
        print("✅ Weekly training days: \(onboardingData.weeklyTrainingDays)")
        print("✅ First name: \(onboardingData.firstName)")
        print("✅ Last name: \(onboardingData.lastName)")
    }
}
