//
//  MainTabView.swift
//  BravoBall
//
//  Created by Jordan on 1/6/25.
//

import Foundation
import SwiftUI
import RiveRuntime 

struct MainTabView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var userManager: UserManager
    @ObservedObject var sessionModel: SessionGeneratorModel
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var showStreakReset: Bool = true
    @State private var streakResetOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            // Main Content
            ZStack(alignment: .bottom) {
                switch appModel.mainTabSelected {
                case 0:
                    SessionGeneratorView(onboardingModel: onboardingModel, appModel: appModel, sessionModel: sessionModel, userManager: userManager)
                case 1:
                    ProgressionView(appModel: appModel, sessionModel: sessionModel)
                case 2:
                    SavedDrillsView(appModel: appModel, sessionModel: sessionModel)
                case 3:
                    ProfileView(onboardingModel: onboardingModel, appModel: appModel, sessionModel: sessionModel, userManager: userManager)
                case 4:
                    // Only show testing view in debug mode
                    if AppSettings.debug {
                        TestingView(appModel: appModel, sessionModel: sessionModel, userManager: userManager)
                    } else {
                        SessionGeneratorView(onboardingModel: onboardingModel, appModel: appModel, sessionModel: sessionModel, userManager: userManager)
                    }
                default:
                    SessionGeneratorView(onboardingModel: onboardingModel, appModel: appModel, sessionModel: sessionModel, userManager: userManager)
                }
                
                // Custom Tab Bar
                VStack(spacing: 0) {
                    Divider()
                        .frame(height: 3)
                        .background(Color.gray.opacity(0.3))
                    
                    HStack(spacing: 0) {
                        CustomTabItem(
                            icon: AnyView(appModel.homeTab.view()),
                            isSelected: appModel.mainTabSelected == 0
                        ) {
                            appModel.mainTabSelected = 0
                        }
                        
                        CustomTabItem(
                            icon: AnyView(appModel.progressTab.view()),
                            isSelected: appModel.mainTabSelected == 1
                        ) {
                            appModel.mainTabSelected = 1
                        }
                        
                        CustomTabItem(
                            icon: AnyView(appModel.savedTab.view()),
                            isSelected: appModel.mainTabSelected == 2
                        ) {
                            appModel.mainTabSelected = 2
                        }
                        
                        CustomTabItem(
                            icon: AnyView(appModel.profileTab.view()),
                            isSelected: appModel.mainTabSelected == 3
                        ) {
                            appModel.mainTabSelected = 3
                        }
                        
                        // Show testing tab only in debug mode
                        if AppSettings.debug {
                            CustomTabItem(
                                icon: AnyView(
                                    Image(systemName: "wrench.and.screwdriver.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(appModel.mainTabSelected == 4 ? .blue : .gray)
                                ),
                                isSelected: appModel.mainTabSelected == 4
                            ) {
                                appModel.mainTabSelected = 4
                            }
                        }
                    }
                    .padding(.horizontal, appModel.layout.contentMinPadding)
                    .frame(height: 70)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)

                // StreakResetView overlay
                if appModel.viewState.showStreakLostMessage && showStreakReset {
                    // Fade background overlay
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(99)
                        .onTapGesture { /* Prevent tap-through */ }
                    StreakResetView(onDismiss: {
                        withAnimation(.spring()) {
                            streakResetOffset = UIScreen.main.bounds.height
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            appModel.viewState.showStreakLostMessage = false
                            showStreakReset = false
                            streakResetOffset = 0
                        }
                    })
                    .offset(y: streakResetOffset)
                    .transition(.move(edge: .top))
                    .zIndex(100)
                    .onAppear {
                        streakResetOffset = 0
                        showStreakReset = true
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    let mockOnboardingModel = OnboardingModel()
    let mockMainAppModel = MainAppModel()
    let mockUserManager = UserManager()
    let mockSesGenModel = SessionGeneratorModel()
    
    return MainTabView(
        onboardingModel: mockOnboardingModel,
        appModel: mockMainAppModel,
        userManager: mockUserManager,
        sessionModel: mockSesGenModel
    )
    .environmentObject(ToastManager())
}
