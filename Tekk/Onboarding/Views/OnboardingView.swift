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
    @Environment(\.dismiss) private var dismiss

    
    var body: some View {
        Group {
            // testing instead of onboarding complete
            if model.isLoggedIn {
                MainTabView(model: model, appModel: appModel, userManager: userManager)
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
//                RiveViewModel(fileName: "BravoBall_Intro").view()
//                    .scaleEffect(model.animationScale)
//                    .edgesIgnoringSafeArea(.all)
//                    .allowsHitTesting(false)
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.7) {
//                            withAnimation(.spring()) {
//                                model.showIntroAnimation = false
//                            }
//                        }
//                    }
            }
        }
        .animation(.spring(), value: model.showWelcome)
        .animation(.spring(), value: model.showLoginPage)
    }
    
    // Welcome view for new users
    var welcomeContent: some View {
        VStack {
//            RiveViewModel(fileName: "Bravo_Panting").view()
//                .frame(width: 300, height: 300)
//                .padding(.top, 30)
//                .padding(.bottom, 10)
            
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
//            RiveViewModel(fileName: "Bravo_Panting").view()
//                .frame(width: 100, height: 100)
//            
            // Step Content
            ScrollView(showsIndicators: false) {
                switch model.currentStep {
                case 0:
                    OnboardingStepView(
                        model: model,
                        title: "What's your age range?",
                        options: model.ageRanges,
                        selection: $model.onboardingData.ageRange
                    )
                case 1:
                    OnboardingStepView(
                        model: model,
                        title: "What's your playing level?",
                        options: model.levels,
                        selection: $model.onboardingData.level
                    )
                case 2:
                    OnboardingStepView(
                        model: model,
                        title: "What position do you play?",
                        options: model.positions,
                        selection: $model.onboardingData.position
                    )
                case 3:
                    OnboardingMultiSelectView(
                        model: model,
                        title: "Which players do you feel represent your playstyle?",
                        options: model.players,
                        selections: $model.onboardingData.playstyleRepresentatives
                    )
                case 4:
                    VStack(spacing: 20) {
                        OnboardingMultiSelectView(
                            model: model,
                            title: "What are your biggest strengths?",
                            options: model.skills,
                            selections: $model.onboardingData.strengths
                        )
                        OnboardingMultiSelectView(
                            model: model,
                            title: "What would you like to work on?",
                            options: model.skills,
                            selections: $model.onboardingData.weaknesses
                        )
                    }
                case 5:
                    OnboardingBooleanView(
                        model: model,
                        title: "Are you currently playing for a team?",
                        selection: $model.onboardingData.hasTeam
                    )
                case 6:
                    OnboardingStepView(
                        model: model,
                        title: "What is your primary goal?",
                        options: model.goals,
                        selection: $model.onboardingData.primaryGoal
                    )
                case 7:
                    OnboardingStepView(
                        model: model,
                        title: "When are you looking to achieve this by?",
                        options: model.timelines,
                        selection: $model.onboardingData.timeline
                    )
                case 8:
                    OnboardingMultiSelectView(
                        model: model,
                        title: "What days would you like to train?",
                        options: model.weekdays,
                        selections: $model.onboardingData.trainingDays
                    )
                case 9:
                    OnboardingMultiSelectView(
                        model: model,
                        title: "What equipment do you have access to?",
                        options: model.equipment,
                        selections: $model.onboardingData.availableEquipment
                    )
                case 10:
                    OnboardingRegisterForm(
                        model: model,
                        title: "Enter your Registration Info below!",
                        firstName: $model.onboardingData.firstName,
                        lastName: $model.onboardingData.lastName,
                        email: $model.onboardingData.email,
                        password: $model.onboardingData.password
                    )
                default:
                    CompletionView(model: model, userManager: userManager)
                }
            }
            .padding()

            
            // Next button
            if model.currentStep < model.numberOfOnboardingPages {
                Button(action: {
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

