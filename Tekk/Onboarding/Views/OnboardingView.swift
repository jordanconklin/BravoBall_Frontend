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
    @State private var hasAttemptedSubmit = false  // New state variable to track submission attempts
    
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
        VStack(spacing: 30) {
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
                
                // if were on the preview page condition
                if onboardingModel.currentStep > 0 {
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(Color.gray.opacity(0.3))
                                .frame(height: 10)
                                .cornerRadius(2)
                            
                            Rectangle()
                                .foregroundColor(onboardingModel.globalSettings.primaryYellowColor)
                                .frame(width: geometry.size.width * min(CGFloat(onboardingModel.currentStep) / CGFloat(onboardingModel.numberOfOnboardingPages - 1), 1.0), height: 10)
                                .cornerRadius(2)
                        }
                    }
                    .frame(height: 10)
                    
                    // Skip Button (always visible, but grayed out and disabled on registration step)
                    Button(action: {
                        if onboardingModel.currentStep != onboardingModel.numberOfOnboardingPages - 1 {
                            withAnimation {
                                onboardingModel.backTransition = false
                                onboardingModel.skipToNext()
                            }
                        }
                    }) {
                        Text("Skip")
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundColor(onboardingModel.currentStep == onboardingModel.numberOfOnboardingPages - 1 ? Color.gray.opacity(0.4) : onboardingModel.globalSettings.primaryDarkColor)
                    }
                    .disabled(onboardingModel.currentStep == onboardingModel.numberOfOnboardingPages - 1)
                } else {
                    Spacer()
                }
                
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            HStack {
                // Mascot
                riveViewModelTwo.view()
                    .frame(width: 100, height: 100)
                if onboardingModel.currentStep > 0 && onboardingModel.currentStep != onboardingModel.numberOfOnboardingPages {
                    ZStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            // Left Pointer
                            Path { path in
                                path.move(to: CGPoint(x: 15, y: 0))
                                path.addLine(to: CGPoint(x: 0, y: 10))
                                path.addLine(to: CGPoint(x: 15, y: 20))
                            }
                            .fill(appModel.globalSettings.primaryLightestGrayColor)
                            .frame(width: 9, height: 20)
                            .offset(x: -5, y: 1)
                            
                            // Text Bubble
                            Text(onboardingModel.currentStep <= 12 ? onboardingModel.questionTitles[onboardingModel.currentStep - 1] : "Enter your Registration Info below!")
                                .font(.custom("Poppins-Bold", size: 16))
                                .foregroundColor(appModel.globalSettings.primaryDarkColor)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(appModel.globalSettings.primaryLightestGrayColor)
                                        .frame(width: 180)
                                )
                                .frame(width: 180)
                        }
                        .offset(x: -10)
                        .transition(.opacity.combined(with: .offset(y: 10)))
                    }
                }
            }
            .padding(.bottom, 20)
            
            
            // Step Content
                if onboardingModel.currentStep < onboardingModel.numberOfOnboardingPages - 1 {
                    switch onboardingModel.currentStep {
                    case 0: OnboardingPreview(
                        appModel: appModel
                    )
                    case 1:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[0],
                            selection: $onboardingModel.onboardingData.primaryGoal
                        )
                    case 2:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[1],
                            selections: $onboardingModel.onboardingData.biggestChallenge
                        )
                    case 3:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[2],
                            selection: $onboardingModel.onboardingData.trainingExperience
                        )
                    case 4:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[3],
                            selection: $onboardingModel.onboardingData.position
                        )
                    case 5:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[4],
                            selections: $onboardingModel.onboardingData.playstyle
                        )
                    case 6:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[5],
                            selection: $onboardingModel.onboardingData.ageRange
                        )
                    case 7:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[6],
                            selections: $onboardingModel.onboardingData.strengths
                        )
                    case 8:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[7],
                            selections: $onboardingModel.onboardingData.areasToImprove
                        )
                    case 9:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[8],
                            selections: $onboardingModel.onboardingData.trainingLocation
                        )
                    case 10:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[9],
                            selections: $onboardingModel.onboardingData.availableEquipment
                        )
                    case 11:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[10],
                            selection: $onboardingModel.onboardingData.dailyTrainingTime
                        )
                    case 12:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[11],
                            selection: $onboardingModel.onboardingData.weeklyTrainingDays
                        )
                    default:
                        EmptyView()
                    }
                } else if onboardingModel.currentStep == onboardingModel.numberOfOnboardingPages - 1 {
                    OnboardingRegisterForm(
                        onboardingModel: onboardingModel,
                        firstName: $onboardingModel.onboardingData.firstName,
                        lastName: $onboardingModel.onboardingData.lastName,
                        email: $onboardingModel.onboardingData.email,
                        password: $onboardingModel.onboardingData.password
                    )
                } else {
                    CompletionView(onboardingModel: onboardingModel, userManager: userManager, sessionModel: sessionModel)
                }
            
            // Next button
            if onboardingModel.currentStep < onboardingModel.numberOfOnboardingPages {
                Button(action: {
                    if onboardingModel.currentStep == onboardingModel.numberOfOnboardingPages - 1 {
                        hasAttemptedSubmit = true  // Set to true when user attempts to submit
                        
                        // Validate registration form fields
                        if let validationError = onboardingModel.registrationValidationError {
                            onboardingModel.errorMessage = validationError
                            return
                        }
                        
                        // Call email pre-check
                        Task {
                            let email = onboardingModel.onboardingData.email
                            let password = onboardingModel.onboardingData.password
                            guard !email.isEmpty, !password.isEmpty else {
                                onboardingModel.errorMessage = "Please enter your email and password."
                                return
                            }
                            onboardingModel.isLoading = true
                            onboardingModel.errorMessage = ""
                            let body = ["email": email]
                            let jsonBody = try? JSONSerialization.data(withJSONObject: body)
                            do {
                                let (data, response) = try await APIService.shared.request(
                                    endpoint: "/check-email/",
                                    method: "POST",
                                    headers: ["Content-Type": "application/json"],
                                    body: jsonBody
                                )
                                if response.statusCode == 200 {
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
                    Text(onboardingModel.currentStep == onboardingModel.numberOfOnboardingPages - 1 ? "Submit" : "Next")
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
                .disabled(
                    onboardingModel.currentStep == onboardingModel.numberOfOnboardingPages - 1
                        ? (!onboardingModel.canMoveNext() || onboardingModel.onboardingData.email.isEmpty || onboardingModel.onboardingData.password.isEmpty)
                        : !onboardingModel.canMoveNext()
                )
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

