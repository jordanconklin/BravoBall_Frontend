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
    @ObservedObject var model: OnboardingModel
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var userManager: UserManager
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Environment(\.dismiss) private var dismiss
    
    let riveViewModelOne = RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 1")
    let riveViewModelTwo = RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 2")
    
    

    
    var body: some View {
        Group {
            // testing instead of onboarding complete
            if model.isLoggedIn {
                MainTabView(model: model, appModel: appModel, userManager: userManager, sessionModel: sessionModel)
            } else if model.skipOnboarding {
                // Skip directly to completion view when toggle is on
                CompletionView(model: model, userManager: userManager, sessionModel: sessionModel)
                    .onAppear {
                        // Make sure test data is applied when the view appears
                        if model.onboardingData.firstName.isEmpty {
                            print("🔄 Applying test data for onboarding...")
                            model.prefillTestData()
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
            if !model.showWelcome && !model.showLoginPage {
                welcomeContent
            }
            
            // Login view with transition
            if model.showLoginPage {
                LoginView(model: model, userManager: userManager)
                    .transition(.move(edge: .bottom))
            }
            
            // Welcome/Questionnaire view with transition
            if model.showWelcome {
                questionnaireContent
                    .transition(.move(edge: .trailing))
            }
            
            // Intro animation overlay
            if model.showIntroAnimation {
                RiveViewModel(fileName: "BravoBall_Intro").view()
                    .scaleEffect(model.animationScale)
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.7) {
                            withAnimation(.spring()) {
                                model.showIntroAnimation = false
                            }
                        }
                    }
            }
        }
        .animation(.spring(), value: model.showWelcome)
        .animation(.spring(), value: model.showLoginPage)
    }
    
    // Welcome view for new users
    var welcomeContent: some View {
        VStack {
            riveViewModelOne.view()
                .frame(width: 300, height: 300)
                .padding(.top, 30)
                .padding(.bottom, 10)
            
            Text("BravoBall")
                .foregroundColor(model.globalSettings.primaryYellowColor)
                .padding(.bottom, 5)
                .font(.custom("PottaOne-Regular", size: 45))
            
            Text("Start Small. Dream Big")
                .foregroundColor(model.globalSettings.primaryDarkColor)
                .padding(.bottom, 100)
                .font(.custom("Poppins-Bold", size: 16))
            
            // Create Account Button
            Button(action: {
                withAnimation(.spring()) {
                    model.showWelcome.toggle()
                }
            }) {
                Text("Create an account")
                    .frame(width: 325, height: 15)
                    .padding()
                    .background(model.globalSettings.primaryYellowColor)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .font(.custom("Poppins-Bold", size: 16))
            }
            .padding(.horizontal)
            .padding(.top, 80)
            
            // Login Button
            Button(action: {
                withAnimation(.spring()) {
                    model.showLoginPage = true
                }
            }) {
                Text("Login")
                    .frame(width: 325, height: 15)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .foregroundColor(model.globalSettings.primaryDarkColor)
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
                        model.backTransition = true
                        model.movePrevious()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(model.globalSettings.primaryDarkColor)
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
                            .foregroundColor(model.globalSettings.primaryYellowColor)
                            .frame(width: geometry.size.width * (CGFloat(model.currentStep) / 11.0), height: 10)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 10)
                
                // Skip Button
                Button(action: {
                    
                    riveViewModelTwo.setInput("user_input", value: false)
                        // Small delay before setting it true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            riveViewModelTwo.setInput("user_input", value: true)
                            // Reset after animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                riveViewModelTwo.setInput("user_input", value: false)
                            }
                        }
                    
                    withAnimation {
                        model.backTransition = false
                        model.skipToNext()
                        
                    }
                }) {
                    Text("Skip")
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(model.globalSettings.primaryDarkColor)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            
            // Mascot
            riveViewModelTwo.view()
                .frame(width: 100, height: 100)
            
            
            // Step Content
            ScrollView(showsIndicators: false) {
                if model.currentStep < model.questionTitles.count {
                    switch model.currentStep {
                    case 0:
                        OnboardingStepView(
                            model: model,
                            title: model.questionTitles[0],
                            options: model.questionOptions[0],
                            selection: $model.onboardingData.primaryGoal
                        )
                    case 1:
                        OnboardingStepView(
                            model: model,
                            title: model.questionTitles[1],
                            options: model.questionOptions[1],
                            selection: $model.onboardingData.biggestChallenge
                        )
                    case 2:
                        OnboardingStepView(
                            model: model,
                            title: model.questionTitles[2],
                            options: model.questionOptions[2],
                            selection: $model.onboardingData.trainingExperience
                        )
                    case 3:
                        OnboardingStepView(
                            model: model,
                            title: model.questionTitles[3],
                            options: model.questionOptions[3],
                            selection: $model.onboardingData.position
                        )
                    case 4:
                        OnboardingStepView(
                            model: model,
                            title: model.questionTitles[4],
                            options: model.questionOptions[4],
                            selection: $model.onboardingData.playstyle
                        )
                    case 5:
                        OnboardingStepView(
                            model: model,
                            title: model.questionTitles[5],
                            options: model.questionOptions[5],
                            selection: $model.onboardingData.ageRange
                        )
                    case 6:
                        OnboardingMultiSelectView(
                            model: model,
                            title: model.questionTitles[6],
                            options: model.questionOptions[6],
                            selections: $model.onboardingData.strengths
                        )
                    case 7:
                        OnboardingMultiSelectView(
                            model: model,
                            title: model.questionTitles[7],
                            options: model.questionOptions[7],
                            selections: $model.onboardingData.areasToImprove
                        )
                    case 8:
                        OnboardingMultiSelectView(
                            model: model,
                            title: model.questionTitles[8],
                            options: model.questionOptions[8],
                            selections: $model.onboardingData.trainingLocation
                        )
                    case 9:
                        OnboardingMultiSelectView(
                            model: model,
                            title: model.questionTitles[9],
                            options: model.questionOptions[9],
                            selections: $model.onboardingData.availableEquipment
                        )
                    case 10:
                        OnboardingStepView(
                            model: model,
                            title: model.questionTitles[10],
                            options: model.questionOptions[10],
                            selection: $model.onboardingData.dailyTrainingTime
                        )
                    case 11:
                        OnboardingStepView(
                            model: model,
                            title: model.questionTitles[11],
                            options: model.questionOptions[11],
                            selection: $model.onboardingData.weeklyTrainingDays
                        )
                    default:
                        EmptyView()
                    }
                } else if model.currentStep == model.questionTitles.count {
                    OnboardingRegisterForm(
                        model: model,
                        title: "Enter your Registration Info below!",
                        firstName: $model.onboardingData.firstName,
                        lastName: $model.onboardingData.lastName,
                        email: $model.onboardingData.email,
                        password: $model.onboardingData.password
                    )
                } else {
                    CompletionView(model: model, userManager: userManager, sessionModel: sessionModel)
                }
            }
            .padding()

            
            // Next button
            if model.currentStep < model.numberOfOnboardingPages {
                Button(action: {
                    
                    riveViewModelTwo.triggerInput("user_input")
                    
                    withAnimation {
                        model.backTransition = false
                        model.moveNext()
                    }
                    
                }) {
                    Text(model.currentStep == 10 ? "Finish" : "Next")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(model.canMoveNext() ? model.globalSettings.primaryYellowColor : model.globalSettings.primaryYellowColor.opacity(0.4))
                        )
                        .foregroundColor(.white)
                        .font(.custom("Poppins-Bold", size: 16))
                }
                .padding(.horizontal)
                .disabled(!model.canMoveNext())
            }
        }
    }
}

