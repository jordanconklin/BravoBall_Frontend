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
    @StateObject private var appModel = MainAppModel()
    @StateObject private var userInfoManager = UserManager()
    @StateObject private var sessionGenModel: SessionGeneratorModel
    @StateObject private var authService = AuthenticationService.shared
    
    // Add loading state for authentication check
    @State private var isCheckingAuth = true
    
    init() {
        let appModel = MainAppModel()
        let onboardingData = OnboardingModel.OnboardingData()
        self._appModel = StateObject(wrappedValue: appModel)
        self._sessionGenModel = StateObject(wrappedValue: SessionGeneratorModel(appModel: appModel, onboardingData: onboardingData))
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                ZStack {
                    
                    // Main content (only show when intro animation is not showing)
                        if onboardingModel.isLoggedIn {
                            MainTabView(onboardingModel: onboardingModel, appModel: appModel, userManager: userInfoManager, sessionModel: sessionGenModel)
                                .onAppear {
                                    // Load data if user has history
                                    if userInfoManager.userHasAccountHistory {
                                        Task {
                                            await sessionGenModel.loadBackendData()
                                            
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
                            OnboardingView(onboardingModel: onboardingModel, appModel: appModel, userManager: userInfoManager, sessionModel: sessionGenModel)
                        }
                    
                    // Rive animation with state machine transitions
                    if onboardingModel.showIntroAnimation || isCheckingAuth {
                        
                        RiveAnimationView(
                            onboardingModel: onboardingModel,
                            fileName: "BravoBall_Intro",
                            stateMachine: "State Machine 1",
                            actionForTrigger: isCheckingAuth,
                            animationScale: onboardingModel.animationScale,
                            triggerName: "Start Intro",
                            completionHandler: {
                                onboardingModel.showIntroAnimation = false
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
                await checkAuthenticationStatus()
            }
        }
    }
    
    // MARK: - Authentication Check
    
    private func checkAuthenticationStatus() async {
        print("\n🔐 ===== STARTING AUTHENTICATION CHECK =====")
        print("📅 Timestamp: \(Date())")
        
        // Check if user has valid stored credentials
        let isAuthenticated = await authService.checkAuthenticationStatus()
        
        // Add a minimum delay to show the loading animation
        try? await Task.sleep(nanoseconds: 00_800_000_000) // 0.8 second delay
        
        await MainActor.run {
            if isAuthenticated {
                // User has valid tokens, restore login state
                print("✅ Authentication check passed - restoring login state")
                
                // Restore user data from keychain
                let userEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? ""
                let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") ?? ""
                
                print("📱 Restoring data - Email: \(userEmail)")
                print("🔑 Restoring data - Access Token: \(accessToken.prefix(20))...")
                
                // Update user manager
                userInfoManager.email = userEmail
                userInfoManager.accessToken = accessToken
                userInfoManager.isLoggedIn = true
                userInfoManager.userHasAccountHistory = true
                
                // Update onboarding model
                onboardingModel.accessToken = accessToken
                onboardingModel.isLoggedIn = true
                
                print("🔑 Restored login state for user: \(userEmail)")
            } else {
                print("❌ Authentication check failed - user needs to login")
                print("📱 No valid tokens found or backend validation failed")
            }
            
            // End loading state
            isCheckingAuth = false
            print("🏁 Authentication check complete - isCheckingAuth: \(isCheckingAuth)")
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(ToastManager())
}

