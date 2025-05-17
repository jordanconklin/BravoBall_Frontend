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
                    // Bravo animation
                    RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 1").view()
                        .frame(width: 150, height: 150)
                        .padding(.top, 50)
                    
                    Text("Creating your session...")
                        .font(.custom("Poppins-Bold", size: 20))
                        .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                    
                    Text("We're personalizing drills based on your preferences")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(onboardingModel.globalSettings.primaryGrayColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
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
                            submitOnboardingData()
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
    
    private func submitOnboardingData() {
        isLoading = true
        errorMessage = ""
        
        OnboardingService.shared.submitOnboardingData(data: onboardingModel.onboardingData) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    // Save the auth token
                    self.onboardingModel.authToken = response.access_token
                    
                    // Update the decoded user info into UserManager
                    self.userManager.updateUserKeychain(
                        email: self.onboardingModel.onboardingData.email,
                        firstName: self.onboardingModel.onboardingData.firstName,
                        lastName: self.onboardingModel.onboardingData.lastName
                    )
                    
                    // Set user as logged in
                    self.onboardingModel.isLoggedIn = true
                    
                case .failure(let error):
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    print("Onboarding submission error: \(error)")
                }
            }
        }
    }
    
    func submitData() {
        isLoading = true
        
        Task {
            do {          
                // // Ensure at least one area to improve is selected
                // if onboardingModel.onboardingData.areasToImprove.isEmpty {
                //     onboardingModel.onboardingData.areasToImprove = ["First touch", "Passing"]
                //     print("⚠️ No areas to improve selected, defaulting to First touch and Passing")
                // }
                
                // // Ensure equipment is not empty
                // if onboardingModel.onboardingData.availableEquipment.isEmpty {
                //     onboardingModel.onboardingData.availableEquipment = ["Soccer ball"]
                //     print("⚠️ No equipment selected, defaulting to Soccer ball")
                // }
                
                // // Ensure training location is not empty
                // if onboardingModel.onboardingData.trainingLocation.isEmpty {
                //     onboardingModel.onboardingData.trainingLocation = ["At a soccer field with goals"]
                //     print("⚠️ No training location selected, defaulting to 'At a soccer field with goals'")
                // }
                
                print("📤 Sending onboarding data: \(onboardingModel.onboardingData)")
                
                // Run the OnboardingService function to submit data
                let response = try await OnboardingService.shared.submitOnboardingData(data: onboardingModel.onboardingData)
                print("✅ Onboarding data submitted successfully")
                print("🔑 Received token: \(response.access_token)")
                
                // Prefill subskills for preferences update
                sessionModel.prefillSelectedSkills(from: onboardingModel.onboardingData)
                
                // Update preferences using onboarding data and subskills
                try await PreferencesUpdateService.shared.updatePreferences(
                    time: onboardingModel.onboardingData.dailyTrainingTime,
                    equipment: Set(onboardingModel.onboardingData.availableEquipment),
                    trainingStyle: onboardingModel.onboardingData.trainingExperience,
                    location: onboardingModel.onboardingData.trainingLocation.first,
                    difficulty: onboardingModel.onboardingData.position,
                    skills: sessionModel.selectedSkills,
                    sessionModel: sessionModel
                )
                
                await MainActor.run {
                    // Store access token taking access token response from the backend response
                    let tokenSaved = KeychainWrapper.standard.set(response.access_token, forKey: "authToken")
                    print("🔑 Token saved to keychain: \(tokenSaved)")
                    
                    // Verify token was stored correctly
                    if let storedToken = KeychainWrapper.standard.string(forKey: "authToken") {
                        print("✅ Verified token in keychain: \(storedToken)")
                    } else {
                        print("❌ Failed to retrieve token from keychain!")
                    }
                    
                    // Update the decoded user info into UserManager, which will store it into Keychain
                    userManager.updateUserKeychain(
                        email: onboardingModel.onboardingData.email,
                        firstName: onboardingModel.onboardingData.firstName,
                        lastName: onboardingModel.onboardingData.lastName
                    )
                    
                    // Set user as logged in
                    onboardingModel.isLoggedIn = true
                    
                    print("✅ Onboarding complete, user logged in")
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
        sessionModel.prefillSelectedSkills(from: onboardingModel.onboardingData)
        sessionModel.loadInitialSession(from: mockSession)
    }
}

