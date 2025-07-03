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
    @ObservedObject var forgotPasswordModel: ForgotPasswordModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var mascotShouldAnimate = false
    @State private var canTrigger = true
    @State private var showEmailExistsAlert = false
    @State private var hasAttemptedSubmit = false  // New state variable to track submission attempts
    
    

    
    var body: some View {
        Group {
            // testing instead of onboarding complete
            if userManager.isLoggedIn {
                MainTabView(onboardingModel: onboardingModel, appModel: appModel, userManager: userManager, sessionModel: sessionModel)
            } else if onboardingModel.skipOnboarding {
                // Skip directly to completion view when toggle is on
                CompletionView(onboardingModel: onboardingModel, userManager: userManager, sessionModel: sessionModel)
            } else {
                content
            }
        }
    }
    
    var content: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // Main content (Bravo and create account / login buttons)
            if !userManager.showWelcome && !userManager.showLoginPage {
                welcomeContent
            }
            
            // Login view with transition
            if userManager.showLoginPage {
                LoginView(onboardingModel: onboardingModel, userManager: userManager, forgotPasswordModel: forgotPasswordModel)
                    .transition(.move(edge: .bottom))
            }
            
            // Welcome/Questionnaire view with transition
            if userManager.showWelcome {
                questionnaireContent
                    .transition(.move(edge: .trailing))
            }
            
            
        }
        .animation(.spring(), value: userManager.showWelcome)
        .animation(.spring(), value: userManager.showLoginPage)
    }
    
    // Welcome view for new users
    var welcomeContent: some View {
        VStack {
            RiveAnimationView(
                userManager: userManager,
                fileName: "Bravo_Animation",
                stateMachine: "State Machine 1",
                actionForTrigger: false,
                triggerName: ""

            )
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
            
            Spacer()
            
            VStack(spacing: 16) {
                
                // Create Account Button
                PrimaryButton(
                    title: "Create an account",
                    action: {
                        Haptic.light()
                        withAnimation(.spring()) {
                            userManager.showWelcome.toggle()
                        }
                    },
                    frontColor: appModel.globalSettings.primaryYellowColor,
                    backColor: appModel.globalSettings.primaryDarkYellowColor,
                    textColor: Color.white,
                    textSize: 18,
                    width: .infinity,
                    height: 50,
                    disabled: false
                )
                .padding(.horizontal)
                
                // Login Button
                PrimaryButton(
                    title: "Login",
                    action: {
                        Haptic.light()
                        withAnimation(.spring()) {
                            userManager.showLoginPage = true
                        }
                    },
                    frontColor: Color.white,
                    backColor: appModel.globalSettings.primaryLightGrayColor,
                    textColor: appModel.globalSettings.primaryYellowColor,
                    textSize: 18,
                    width: .infinity,
                    height: 50,
                    borderColor: appModel.globalSettings.primaryLightGrayColor,
                    disabled: false
                )
                .padding(.horizontal)
                
            }
            .padding(.bottom, 24)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
    }
    
    // Questionnaire view for onboarding new users
    var questionnaireContent: some View {
        VStack(spacing: 30) {
            // Top Navigation Bar
            HStack(spacing: 12) {
                // Back Button
                Button(action: {
                    Haptic.light()
                    withAnimation {
                        onboardingModel.backTransition = true
                        onboardingModel.movePrevious(userManager: userManager)
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
                        Haptic.light()
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
                RiveAnimationView(
                    userManager: userManager,
                    fileName: "Bravo_Animation",
                    stateMachine: "State Machine 2",
                    actionForTrigger: mascotShouldAnimate,
                    triggerName: "user_inputs"

                )
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
                            Text(onboardingModel.currentStep < onboardingModel.questionTitles.count + 1 ? onboardingModel.questionTitles[onboardingModel.currentStep - 1] : "Enter your Registration Info below!")
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
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[1],
                            selection: $onboardingModel.onboardingData.trainingExperience
                        )
                    case 3:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[2],
                            selection: $onboardingModel.onboardingData.position
                        )
                    case 4:
                        OnboardingStepView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[3],
                            selection: $onboardingModel.onboardingData.ageRange
                        )
                    case 5:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[4],
                            selections: $onboardingModel.onboardingData.strengths
                        )
                    case 6:
                        OnboardingMultiSelectView(
                            onboardingModel: onboardingModel,
                            options: onboardingModel.questionOptions[5],
                            selections: $onboardingModel.onboardingData.areasToImprove
                        )
                    default:
                        EmptyView()
                    }
                } else if onboardingModel.currentStep == onboardingModel.numberOfOnboardingPages - 1 {
                    OnboardingRegisterForm(
                        onboardingModel: onboardingModel,
                        email: $onboardingModel.onboardingData.email,
                        password: $onboardingModel.onboardingData.password
                    )
                } else {
                    CompletionView(onboardingModel: onboardingModel, userManager: userManager, sessionModel: sessionModel)
                }
            
            // Next button
            if onboardingModel.currentStep < onboardingModel.numberOfOnboardingPages {
                
                PrimaryButton(
                    title: onboardingModel.currentStep == onboardingModel.numberOfOnboardingPages - 1 ? "Submit" : "Next",
                    action: nextButtonLogic,
                    frontColor: onboardingModel.globalSettings.primaryYellowColor,
                    backColor: onboardingModel.globalSettings.primaryDarkYellowColor,
                    textColor: Color.white,
                    textSize: 16,
                    width: .infinity,
                    height: 50,
                    disabled: nextButtonDisabledLogic()
                )
                .padding(.horizontal)
                .padding(.bottom, 24)
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
    
    func nextButtonLogic() {
        Haptic.light()
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
                let confirmPassword = onboardingModel.onboardingData.confirmPassword
                guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
                    onboardingModel.errorMessage = "Please enter your email and passwords."
                    return
                }
                onboardingModel.isLoading = true
                onboardingModel.errorMessage = ""
                let body = ["email": email]
                let jsonBody = try? JSONSerialization.data(withJSONObject: body)
                do {
                    let (data, response) = try await APIService.shared.request(
                        endpoint: "/check-unique-email/",
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
            mascotShouldAnimate = true
            withAnimation {
                onboardingModel.backTransition = false
                onboardingModel.moveNext()
            }
            
            // Optionally, reset the trigger after a delay (match your animation duration)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    mascotShouldAnimate = false
                }
        }

    }
    
    func nextButtonDisabledLogic() -> Bool {
        onboardingModel.currentStep == onboardingModel.numberOfOnboardingPages - 1
            ? (!onboardingModel.canMoveNext() || onboardingModel.onboardingData.email.isEmpty || onboardingModel.onboardingData.password.isEmpty || onboardingModel.onboardingData.confirmPassword.isEmpty)
            : !onboardingModel.canMoveNext()
    }
    
}


