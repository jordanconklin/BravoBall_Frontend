//
//  LaunchScreenView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/2/25.
//

import SwiftUI
import RiveRuntime

// Main onboarding view
struct LaunchScreenView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var userManager: UserManager
    @ObservedObject var sessionModel: SessionGeneratorModel
    @ObservedObject var forgotPasswordModel: ForgotPasswordModel
    @ObservedObject var loginModel: LoginModel
    let globalSettings = GlobalSettings.shared
    
    

    
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
            
            // Launch screen content (Bravo and create account / login buttons)
            if !userManager.showWelcome && !userManager.showLoginPage {
                welcomeContent
            }
            
            // Login view with transition
            if userManager.showLoginPage {
                LoginView(userManager: userManager, forgotPasswordModel: forgotPasswordModel, loginModel: loginModel)
                    .transition(.move(edge: .bottom))
            }
            
            // Welcome/Questionnaire view with transition
            if userManager.showWelcome {
                OnboardingView(onboardingModel: onboardingModel, appModel: appModel, userManager: userManager, sessionModel: sessionModel)
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
                .foregroundColor(globalSettings.primaryYellowColor)
                .padding(.bottom, 5)
                .font(.custom("PottaOne-Regular", size: 45))
            
            Text("Start Small. Dream Big")
                .foregroundColor(globalSettings.primaryDarkColor)
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
                    frontColor: globalSettings.primaryYellowColor,
                    backColor: globalSettings.primaryDarkYellowColor,
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
                    backColor: globalSettings.primaryLightGrayColor,
                    textColor: globalSettings.primaryYellowColor,
                    textSize: 18,
                    width: .infinity,
                    height: 50,
                    borderColor: globalSettings.primaryLightGrayColor,
                    disabled: false
                )
                .padding(.horizontal)
                
            }
            .padding(.bottom, 24)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
    }
    
}


