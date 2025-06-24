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
    @StateObject private var sessionGenModel = SessionGeneratorModel(appModel: MainAppModel(), onboardingData: OnboardingModel.OnboardingData())



    var body: some View {
        GeometryReader { geometry in
            Group {
                
                if onboardingModel.isLoggedIn {
                    MainTabView(onboardingModel: onboardingModel, appModel: appModel, userManager: userInfoManager, sessionModel: sessionGenModel)
                        .onAppear {
                            // Load cached data if user has history
                            if userInfoManager.userHasAccountHistory {
                                appModel.loadCachedData()
                                sessionGenModel.loadCachedData()
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

