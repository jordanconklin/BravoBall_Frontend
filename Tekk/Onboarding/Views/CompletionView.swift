//
//  CompletionView.swift
//  BravoBall
//
//  Created by Jordan on 1/7/25.
//

import SwiftUI
import RiveRuntime
import SwiftKeychainWrapper

struct CompletionView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var userManager: UserManager
    @ObservedObject var sessionModel: SessionGeneratorModel
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            if isLoading {
                // Loading screen with Bravo
                VStack(spacing: 20) {
                    // Loading text and spinner directly below Bravo
                    Text("Creating your session...")
                        .font(.custom("Poppins-Bold", size: 20))
                        .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                        .offset(y: -5)

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                        .offset(y: -5)

                    Text("We're personalizing drills based on your preferences")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(onboardingModel.globalSettings.primaryGrayColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .offset(y: -5)

                    Spacer()
                }
                .padding()
            } else {
                // Fallback view in case isLoading not set to true
                VStack(spacing: 20) {
                    // Bravo image
                    RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 1").view()
                        .frame(width: 150, height: 150)
                        .padding(.top, 50)
                    
                    Text("You're all set!")
                        .font(.custom("Poppins-Bold", size: 24))
                        .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                    
                    Text("Thanks for completing the onboarding process. We've created a personalized training plan for you.")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(onboardingModel.globalSettings.primaryGrayColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Error message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            submitData()
                        }
                    }) {
                        Text("Start Training")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(width: 280, height: 50)
                            .background(onboardingModel.globalSettings.primaryYellowColor)
                            .cornerRadius(25)
                    }
                    .padding(.bottom, 50)
                }
                .padding()
            }
        }
        .onAppear {
            submitData()
        }
    }
    
    func submitData() {
        isLoading = true
        
        Task {
            do {
                print("--- Onboarding: Starting submitData ---")
                print("[Before Onboarding] selectedSkills: \(sessionModel.selectedSkills)")
                print("[Before Onboarding] selectedTime: \(sessionModel.selectedTime ?? "nil")")
                print("[Before Onboarding] selectedEquipment: \(sessionModel.selectedEquipment)")
                print("[Before Onboarding] selectedTrainingStyle: \(sessionModel.selectedTrainingStyle ?? "nil")")
                print("[Before Onboarding] selectedLocation: \(sessionModel.selectedLocation ?? "nil")")
                print("[Before Onboarding] selectedDifficulty: \(sessionModel.selectedDifficulty ?? "nil")")
                
                print("📤 Sending onboarding data: \(onboardingModel.onboardingData)")
                
                // Run the OnboardingService function to submit data
                let response = try await OnboardingService.shared.submitOnboardingData(data: onboardingModel.onboardingData)
                print("✅ Onboarding data submitted successfully")
                print("🔑 Received token: \(response.access_token)")
                
                // Store access token taking access token response from the backend response
                let tokenSaved = KeychainWrapper.standard.set(response.access_token, forKey: "authToken")
                print("🔑 Token saved to keychain: \(tokenSaved)")
                // Verify token was stored correctly
                if let storedToken = KeychainWrapper.standard.string(forKey: "authToken") {
                    print("✅ Verified token in keychain: \(storedToken)")
                } else {
                    print("❌ Failed to retrieve token from keychain!")
                }
                
                // Prefill subskills for preferences update
                await sessionModel.prefillSelectedSkills(from: onboardingModel.onboardingData)
                print("[After prefillSelectedSkills] selectedSkills: \(sessionModel.selectedSkills)")
                
                // Update preferences using onboarding data and subskills, which will help preload our session after onboarding
                try await PreferencesUpdateService.shared.updatePreferences(
                    time: onboardingModel.onboardingData.dailyTrainingTime,
                    equipment: Set(onboardingModel.onboardingData.availableEquipment),
                    trainingStyle: onboardingModel.onboardingData.trainingExperience,
                    location: onboardingModel.onboardingData.trainingLocation.first,
                    difficulty: onboardingModel.onboardingData.position,
                    skills: sessionModel.selectedSkills,
                    sessionModel: sessionModel
                )
                
                // Prefill preferences for session generator model using onboarding data
                await sessionModel.prefillPreferences(from: onboardingModel.onboardingData)
                
                print("[After updatePreferences] selectedSkills: \(sessionModel.selectedSkills)")
                print("[After updatePreferences] selectedTime: \(sessionModel.selectedTime ?? "nil")")
                print("[After updatePreferences] selectedEquipment: \(sessionModel.selectedEquipment)")
                print("[After updatePreferences] selectedTrainingStyle: \(sessionModel.selectedTrainingStyle ?? "nil")")
                print("[After updatePreferences] selectedLocation: \(sessionModel.selectedLocation ?? "nil")")
                print("[After updatePreferences] selectedDifficulty: \(sessionModel.selectedDifficulty ?? "nil")")
                
                await MainActor.run {
                    // Update the decoded user info into UserManager, which will store it into Keychain
                    userManager.updateUserKeychain(
                        email: onboardingModel.onboardingData.email,
                        firstName: onboardingModel.onboardingData.firstName,
                        lastName: onboardingModel.onboardingData.lastName
                    )
                    
                    // Set user as logged in
                    onboardingModel.isLoggedIn = true
                    // Clear onboarding data
                    onboardingModel.resetOnboardingData()
                    
                    print("✅ Onboarding complete, user logged in")
                    print("[UI] selectedSkills: \(sessionModel.selectedSkills)")
                    print("[UI] selectedTime: \(sessionModel.selectedTime ?? "nil")")
                    print("[UI] selectedEquipment: \(sessionModel.selectedEquipment)")
                    print("[UI] selectedTrainingStyle: \(sessionModel.selectedTrainingStyle ?? "nil")")
                    print("[UI] selectedLocation: \(sessionModel.selectedLocation ?? "nil")")
                    print("[UI] selectedDifficulty: \(sessionModel.selectedDifficulty ?? "nil")")
                }
            } catch let error as DecodingError {
                await MainActor.run {
                    handleDecodingError(error)
                }
            } catch let error as NSError {
                await MainActor.run {
                    onboardingModel.errorMessage = "Server Error (\(error.code)): \(error.localizedDescription)"
                    print("❌ Detailed error: \(error)")
                    print("❌ Error domain: \(error.domain)")
                    print("❌ Error code: \(error.code)")
                    print("❌ Error user info: \(error.userInfo)")
                    
                    // If this is a validation error, don't proceed
                    if error.domain != "CompletionView" {
                        // For server errors, we can still proceed with a default session
                        createDefaultSession()
                        onboardingModel.isLoggedIn = true
                    }
                }
            } catch {
                await MainActor.run {
                    onboardingModel.errorMessage = "Error: \(error.localizedDescription)"
                    print("❌ Error submitting onboarding data: \(error)")
                }
            }
        }
    }
    
    private func handleDecodingError(_ error: DecodingError) {
        switch error {
        case .typeMismatch(let type, let context):
            onboardingModel.errorMessage = "Type mismatch: Expected \(type) but found something else."
            print("❌ Type mismatch at path: \(context.codingPath)")
            print("❌ Debug description: \(context.debugDescription)")
            
            // If the error is related to the initial session, we can still proceed
            if context.codingPath.contains(where: { $0.stringValue == "initial_session" }) {
                print("⚠️ Error in initial session data, creating default session")
                createDefaultSession()
                onboardingModel.isLoggedIn = true
            }
        case .valueNotFound(let type, let context):
            onboardingModel.errorMessage = "Value not found: Expected \(type) but found null."
            print("❌ Value not found at path: \(context.codingPath)")
            
            // If the error is related to the initial session, drills, sets, or reps, we can still proceed
            if context.codingPath.contains(where: { $0.stringValue == "initial_session" }) ||
               context.codingPath.contains(where: { $0.stringValue == "drills" }) ||
               context.codingPath.contains(where: { $0.stringValue == "sets" }) ||
               context.codingPath.contains(where: { $0.stringValue == "reps" }) {
                print("⚠️ Error in initial session data, creating default session")
                createDefaultSession()
                onboardingModel.isLoggedIn = true
            }
        case .keyNotFound(let key, let context):
            onboardingModel.errorMessage = "Key not found: \(key.stringValue)"
            print("❌ Key not found at path: \(context.codingPath)")
        case .dataCorrupted(let context):
            onboardingModel.errorMessage = "Data corrupted: \(context.debugDescription)"
            print("❌ Data corrupted at path: \(context.codingPath)")
        @unknown default:
            onboardingModel.errorMessage = "Unknown decoding error"
        }
    }
    
    private func createDefaultSession() {
        print("🔄 Creating default session based on user preferences")
        
        // Create a mock session response with default drills
        let mockSession = SessionResponse(
            sessionId: 0,
            totalDuration: 45,
            focusAreas: onboardingModel.onboardingData.areasToImprove,
            drills: []
        )
        
        // Load the mock session
        sessionModel.loadInitialSession(from: mockSession)
    }
}

#if DEBUG
struct CompletionView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock models for preview
        let onboardingModel = OnboardingModel()
        let userManager = UserManager()
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
        
        // Optionally set some mock data for a more realistic preview
        onboardingModel.onboardingData.firstName = "Jordan"
        onboardingModel.onboardingData.lastName = "Conklin"
        onboardingModel.onboardingData.email = "jordan@example.com"
        
        return CompletionView(
            onboardingModel: onboardingModel,
            userManager: userManager,
            sessionModel: sessionModel
        )
    }
}
#endif

