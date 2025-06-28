////
////  ContentView.swift
////  Tekk
////
////  Created by Jordan on 7/9/24.
////  This file contains the main view of the app.

import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingModel = OnboardingModel()
    @StateObject private var appModel = MainAppModel()
    @StateObject private var userInfoManager = UserManager()
    @StateObject private var sessionGenModel: SessionGeneratorModel
    
    init() {
        let appModel = MainAppModel()
        let onboardingData = OnboardingModel.OnboardingData()
        self._appModel = StateObject(wrappedValue: appModel)
        self._sessionGenModel = StateObject(wrappedValue: SessionGeneratorModel(appModel: appModel, onboardingData: onboardingData))
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                
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
            }
            .preferredColorScheme(.light)
            .environment(\.viewGeometry, ViewGeometry(
                size: geometry.size,
                safeAreaInsets: geometry.safeAreaInsets
            ))
            .toastOverlay()
        }
        
    
        
    }
}

#Preview {
    ContentView()
        .environmentObject(ToastManager())
}

