////
////  ContentView.swift
////  Tekk
////
////  Created by Jordan on 7/9/24.
////  This file contains the main view of the app.

import SwiftUI

@main
struct BravoBallApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


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
                            // Only load cache and sync with backend after onboarding is complete
                            if onboardingModel.onboardingComplete {
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

        }
    }
}

#Preview {
    ContentView()
}
