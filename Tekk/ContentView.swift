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
                    MainTabView(model: onboardingModel, appModel: appModel, userManager: userInfoManager, sessionModel: sessionGenModel)
                        .onAppear {
                            // Reload user data when login state changes to true
                            appModel.loadCachedData()
                            sessionGenModel.loadCachedData()
                        }
                    
                } else {
                    OnboardingView(model: onboardingModel, appModel: appModel, userManager: userInfoManager, sessionModel: sessionGenModel)
                }
    //              DragDropTest()
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
