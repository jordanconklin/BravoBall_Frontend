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
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Main Content
                ZStack {
                    switch appModel.mainTabSelected {
                    case 0:
                        SessionGeneratorView(onboardingModel: onboardingModel, appModel: appModel, sessionModel: sessionModel, userManager: userManager)
                    case 1:
                        ProgressionView(appModel: appModel, sessionModel: sessionModel)
                    case 2:
                        SavedDrillsView(appModel: appModel, sessionModel: sessionModel)
                    case 3:
                        ProfileView(onboardingModel: onboardingModel, appModel: appModel, sessionModel: sessionModel, userManager: userManager)
                    default:
                        SessionGeneratorView(onboardingModel: onboardingModel, appModel: appModel, sessionModel: sessionModel, userManager: userManager)
                    }
                }
                .frame(maxWidth: .infinity)

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
                    }
                    .padding(.horizontal, appModel.layout.contentMinPadding)
                    .frame(height: 70)
                }
                .background(Color.white)
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
    let mockSesGenModel = SessionGeneratorModel(appModel: MainAppModel(), onboardingData: OnboardingModel.OnboardingData())
    
    return MainTabView(
        onboardingModel: mockOnboardingModel,
        appModel: mockMainAppModel,
        userManager: mockUserManager,
        sessionModel: mockSesGenModel
    )
    .environmentObject(ToastManager())
}
