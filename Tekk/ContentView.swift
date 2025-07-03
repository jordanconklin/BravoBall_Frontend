////
////  ContentView.swift
////  Tekk
////
////  Created by Jordan on 7/9/24.
////  This file contains the main view of the app.

import SwiftUI
import SwiftKeychainWrapper
import RiveRuntime

struct ContentView: View {
    @StateObject private var onboardingModel = OnboardingModel()
    @StateObject private var forgotPasswordModel = ForgotPasswordModel()
    @StateObject private var loginModel = LoginModel()
    @StateObject private var appModel = MainAppModel()
    @StateObject private var userInfoManager = UserManager()
    @StateObject private var sessionGenModel = SessionGeneratorModel()
    @StateObject private var authService = AuthenticationService.shared
    


    var body: some View {
        GeometryReader { geometry in
            Group {
                ZStack {
                    
                    // Main content (only show when intro animation is not showing)
                        if userInfoManager.isLoggedIn {
                            MainTabView(onboardingModel: onboardingModel, appModel: appModel, userManager: userInfoManager, sessionModel: sessionGenModel)
                                .onAppear {
                                    // Load data if user has history
                                    if userInfoManager.userHasAccountHistory {
                                        Task {
                                            await userInfoManager.loadBackendData(appModel: appModel, sessionModel: sessionGenModel)
                                            
                                            // Set isInitialLoad to false after data loading is complete
                                            await MainActor.run {
                                                sessionGenModel.isInitialLoad = false
                                                appModel.isInitialLoad = false
                                                print("✅ Initialization complete - isInitialLoad set to false")
                                            }
                                        }
                                    } else {
                                        // If no user history, set isInitialLoad to false immediately
                                        sessionGenModel.isInitialLoad = false
                                        appModel.isInitialLoad = false
                                        print("✅ Initialization complete - isInitialLoad set to false (no user history)")
                                    }
                                }
                        } else {
                            LaunchScreenView(onboardingModel: onboardingModel, appModel: appModel, userManager: userInfoManager, sessionModel: sessionGenModel, forgotPasswordModel: forgotPasswordModel, loginModel: loginModel)
                        }
                    
                    // Rive animation with state machine transitions
                    if userInfoManager.showIntroAnimation || authService.isCheckingAuth {
                        
                        RiveAnimationView(
                            userManager: userInfoManager,
                            fileName: "BravoBall_Intro",
                            stateMachine: "State Machine 1",
                            actionForTrigger: authService.isCheckingAuth,
                            animationScale: onboardingModel.animationScale,
                            triggerName: "Start Intro",
                            completionHandler: {
                                userInfoManager.showIntroAnimation = false
                            }

                        )
                    }
                }
            }
            .preferredColorScheme(.light)
            .environment(\.viewGeometry, ViewGeometry(
                size: geometry.size,
                safeAreaInsets: geometry.safeAreaInsets
            ))
            .toastOverlay()
        }
        .onAppear {
            Task {
                await authService.updateAuthenticationStatus(onboardingModel: onboardingModel, userManager: userInfoManager)
            }
        }
    }
    
}


#Preview {
    ContentView()
        .environmentObject(ToastManager())
}

