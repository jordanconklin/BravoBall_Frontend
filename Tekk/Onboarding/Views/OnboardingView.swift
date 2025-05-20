//
//  OnboardingViewTest.swift
//  BravoBall
//
//  Created by Jordan on 1/6/25.
//

import SwiftUI
import RiveRuntime

// Main onboarding view
struct OnboardingView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var userManager: UserManager
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var canTrigger = true
    @State private var showEmailExistsAlert = false
    
    let riveViewModelOne = RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 1")
    let riveViewModelTwo = RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 2", autoPlay: true)
    
    

    
    var body: some View {
        Group {
            // testing instead of onboarding complete
            if onboardingModel.isLoggedIn {
                MainTabView(onboardingModel: onboardingModel, appModel: appModel, userManager: userManager, sessionModel: sessionModel)
            } else if onboardingModel.skipOnboarding {
                // Skip directly to completion view when toggle is on
                CompletionView(onboardingModel: onboardingModel, userManager: userManager, sessionModel: sessionModel)
                    .onAppear {
                        // Make sure test data is applied when the view appears
                        if onboardingModel.onboardingData.firstName.isEmpty {
                            print("🔄 Applying test data for onboarding...")
                            onboardingModel.prefillTestData()
                        }
                    }
            } else {
                content
            }
        }
    }
    
    var content: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // Main content (Bravo and create account / login buttons)
            if !onboardingModel.showWelcome && !onboardingModel.showLoginPage {
                welcomeContent
            }
            
            // Login view with transition
            if onboardingModel.showLoginPage {
                LoginView(onboardingModel: onboardingModel, userManager: userManager)
                    .transition(.move(edge: .bottom))
            }
            
            // Welcome/Questionnaire view with transition
            if onboardingModel.showWelcome {
                questionnaireContent
                    .transition(.move(edge: .trailing))
            }
            
            // Intro animation overlay
            if onboardingModel.showIntroAnimation {
                RiveViewModel(fileName: "BravoBall_Intro").view()
                    .scaleEffect(onboardingModel.animationScale)
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.7) {
                            withAnimation(.spring()) {
                                onboardingModel.showIntroAnimation = false
                            }
                        }
                    }
            }
        }
        .animation(.spring(), value: onboardingModel.showWelcome)
        .animation(.spring(), value: onboardingModel.showLoginPage)
    }
    
    // Welcome view for new users
    var welcomeContent: some View {
        VStack {
            riveViewModelOne.view()
                .frame(width: 300, height: 300)
                .padding(.top, 30)
                .padding(.bottom, 10)
            
            Text("BravoBall")
                .foregroundColor(onboardingModel.globalSettings.primaryYellowColor)
                .padding(.bottom, 5)
                .font(.custom("PottaOne-Regular", size: 45))
            
            Text("Start Small. Dream Big")
                .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                .padding(.bottom, 100)
                .font(.custom("Poppins-Bold", size: 16))
            
            // Create Account Button
            Button(action: {
                withAnimation(.spring()) {
                    onboardingModel.showWelcome.toggle()
                }
            }) {
                Text("Create an account")
                    .frame(width: 325, height: 15)
                    .padding()
                    .background(onboardingModel.globalSettings.primaryYellowColor)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .font(.custom("Poppins-Bold", size: 16))
            }
            .padding(.horizontal)
            .padding(.top, 80)
            
            // Login Button
            Button(action: {
                withAnimation(.spring()) {
                    onboardingModel.showLoginPage = true
                }
            }) {
                Text("Login")
                    .frame(width: 325, height: 15)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                    .cornerRadius(20)
                    .font(.custom("Poppins-Bold", size: 16))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(.white)
    }
    
    // Questionnaire view for onboarding new users
    var questionnaireContent: some View {
        VStack(spacing: 16) {
            // Top Navigation Bar
            HStack(spacing: 12) {
                // Back Button
                Button(action: {
                    withAnimation {
                        onboardingModel.backTransition = true
                        onboardingModel.movePrevious()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                        .imageScale(.large)
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundColor(Color.gray.opacity(0.3))
                            .frame(height: 10)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .foregroundColor(onboardingModel.globalSettings.primaryYellowColor)
                            .frame(width: geometry.size.width * (CGFloat(onboardingModel.currentStep) / 11.0), height: 10)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 10)
                
                // Skip Button
                Button(action: {
                    
                    
                    withAnimation {
                        onboardingModel.backTransition = false
                        onboardingModel.skipToNext()
                        
                    }
                }) {
                    Text("Skip")
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            
            // Mascot
            riveViewModelTwo.view()
                .frame(width: 100, height: 100)
            
            
            // Step Content
            ScrollView(showsIndicators: false) {
                if onboardingModel.currentStep < onboardingModel.questionTitles.count {
                    switch onboardingModel.currentStep {
                    case 0:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[0],
                            options: onboardingModel.questionOptions[0],
                            selection: $onboardingModel.onboardingData.primaryGoal
                        )
                    case 1:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[1],
                            options: onboardingModel.questionOptions[1],
                            selection: $onboardingModel.onboardingData.biggestChallenge
                        )
                    case 2:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[2],
                            options: onboardingModel.questionOptions[2],
                            selection: $onboardingModel.onboardingData.trainingExperience
                        )
                    case 3:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[3],
                            options: onboardingModel.questionOptions[3],
                            selection: $onboardingModel.onboardingData.position
                        )
                    case 4:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[4],
                            options: onboardingModel.questionOptions[4],
                            selection: $onboardingModel.onboardingData.playstyle
                        )
                    case 5:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[5],
                            options: onboardingModel.questionOptions[5],
                            selection: $onboardingModel.onboardingData.ageRange
                        )
                    case 6:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[6],
                            options: onboardingModel.questionOptions[6],
                            selections: $onboardingModel.onboardingData.strengths
                        )
                    case 7:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[7],
                            options: onboardingModel.questionOptions[7],
                            selections: $onboardingModel.onboardingData.areasToImprove
                        )
                    case 8:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[8],
                            options: onboardingModel.questionOptions[8],
                            selections: $onboardingModel.onboardingData.trainingLocation
                        )
                    case 9:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[9],
                            options: onboardingModel.questionOptions[9],
                            selections: $onboardingModel.onboardingData.availableEquipment
                        )
                    case 10:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[10],
                            options: onboardingModel.questionOptions[10],
                            selection: $onboardingModel.onboardingData.dailyTrainingTime
                        )
                    case 11:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            title: onboardingModel.questionTitles[11],
                            options: onboardingModel.questionOptions[11],
                            selection: $onboardingModel.onboardingData.weeklyTrainingDays
                        )
                    default:
                        EmptyView()
                    }
                } else if onboardingModel.currentStep == onboardingModel.questionTitles.count {
                    OnboardingRegisterForm(
                        onboardingModel: onboardingModel,
                        title: "Enter your Registration Info below!",
                        firstName: $onboardingModel.onboardingData.firstName,
                        lastName: $onboardingModel.onboardingData.lastName,
                        email: $onboardingModel.onboardingData.email,
                        password: $onboardingModel.onboardingData.password
                    )
                } else {
                    CompletionView(onboardingModel: onboardingModel, userManager: userManager, sessionModel: sessionModel)
                }
            }
            .padding()

            
            // Next button
            if onboardingModel.currentStep < onboardingModel.numberOfOnboardingPages {
                Button(action: {
                    if onboardingModel.currentStep == 12 {
                        // Call email pre-check
                        Task {
                            let email = onboardingModel.onboardingData.email
                            guard !email.isEmpty else {
                                onboardingModel.errorMessage = "Please enter your email."
                                return
                            }
                            onboardingModel.isLoading = true
                            onboardingModel.errorMessage = ""
                            let url = URL(string: "http://127.0.0.1:8000/check-email/")!
                            var request = URLRequest(url: url)
                            request.httpMethod = "POST"
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            let body = ["email": email]
                            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                            do {
                                let (data, response) = try await URLSession.shared.data(for: request)
                                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                                       let exists = json["exists"] as? Bool {
                                        if exists {
                                            await MainActor.run {
                                                onboardingModel.isLoading = false
                                                showEmailExistsAlert = true
                                            }
                                            return
                                        } else {
                                            // Email is available, proceed with onboarding
                                            await MainActor.run {
                                                onboardingModel.errorMessage = ""
                                                onboardingModel.isLoading = false
                                                triggerBravoAnimation()
                                                withAnimation {
                                                    onboardingModel.backTransition = false
                                                    onboardingModel.moveNext()
                                                }
                                            }
                                        }
                                    } else {
                                        await MainActor.run {
                                            onboardingModel.errorMessage = "Unexpected response from server."
                                            onboardingModel.isLoading = false
                                        }
                                    }
                                } else {
                                    await MainActor.run {
                                        onboardingModel.errorMessage = "Failed to check email. Please try again."
                                        onboardingModel.isLoading = false
                                    }
                                }
                            } catch {
                                await MainActor.run {
                                    onboardingModel.errorMessage = "Network error. Please try again."
                                    onboardingModel.isLoading = false
                                }
                            }
                        }
                    } else {
                        triggerBravoAnimation()
                        withAnimation {
                            onboardingModel.backTransition = false
                            onboardingModel.moveNext()
                        }
                    }
                }) {
                    Text(onboardingModel.currentStep == 12 ? "Submit" : "Next")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(onboardingModel.canMoveNext() ? onboardingModel.globalSettings.primaryYellowColor : onboardingModel.globalSettings.primaryLightGrayColor)
                        )
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Bold", size: 16))
                }
                .padding(.horizontal)
                .disabled(!onboardingModel.canMoveNext())
                .alert(isPresented: $showEmailExistsAlert) {
                    Alert(
                        title: Text("Email Already Registered"),
                        message: Text("This email is already in use. Please use a different email address."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
    func triggerBravoAnimation() {
            guard canTrigger else { return }
            
            // Disable triggering
            canTrigger = false
            
            // Trigger the animation
            riveViewModelTwo.setInput("user_input", value: true)
            
            // Wait for the full animation cycle (3 seconds + a small buffer)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                // Reset the trigger
                riveViewModelTwo.setInput("user_input", value: false)
                // Re-enable triggering
                canTrigger = true
            }
        }
}

