////
////  WelcomeView.swift
////  BravoBall
////
////  Created by Josh on 9/28/24.
////  This file contains the LoginView, which is used to welcome the user.
//
//import SwiftUI
//import RiveRuntime
//
//struct WelcomeView: View {
//    @StateObject private var globalSettings = GlobalSettings()
//    @EnvironmentObject var stateManager: OnboardingStateManager
//    @EnvironmentObject var onboardingCoordinator: OnboardingCoordinator
//    @EnvironmentObject var bravoCoordinator: BravoCoordinator
//    
//    // State for the welcome flow
//    @State private var welcomeInput: Int = 0
//    @State private var firstName = ""
//    @State private var lastName = ""
//    @State private var selectedAge: String = "Select your Age"
//    @State private var selectedLevel: String = "Select your Level"
//    @State private var selectedPosition: String = "Select your Position"
//    @State private var animationStage = 0
//    
//    var body: some View {
//        ZStack {
//            Color.white.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                // Back button
//                HStack {
//                    Button(action: handleBack) {
//                        Image(systemName:"arrow.left")
//                            .font(.title2)
//                            .foregroundColor(globalSettings.primaryDarkColor)
//                            .padding()
//                    }
//                    Spacer()
//                }
//                .padding(.top)
//                
//                if animationStage >= 3 {
//                    ZStack {
//                        // Bravo Animation
//                        BravoView()
//                            .frame(width: 250, height: 250)
//                            .padding(.bottom, 5)
//                            .offset(x: bravoCoordinator.position.width, 
//                                   y: bravoCoordinator.position.height)
//                        
//                        // Questions form
//                        WelcomeQuestions(
//                            welcomeInput: $welcomeInput,
//                            firstName: $firstName,
//                            lastName: $lastName,
//                            selectedAge: $selectedAge,
//                            selectedLevel: $selectedLevel,
//                            selectedPosition: $selectedPosition
//                        )
//                        .transition(.opacity.combined(with: .move(edge: .trailing)))
//                        .animation(.easeInOut(duration: 0.3), value: animationStage)
//                    }
//                } else {
//                    Spacer()
//                    BravoView()
//                    Text(onboardingCoordinator.currentStep.bravoMessage)
//                        .foregroundColor(globalSettings.primaryDarkColor)
//                        .padding(.horizontal, 80)
//                        .multilineTextAlignment(.center)
//                        .opacity(animationStage == 0 ? 1 : 0)
//                        .animation(.easeOut(duration: 0.2), value: animationStage)
//                        .font(.custom("Poppins-Bold", size: 16))
//                    Spacer()
//                }
//                
//                // Next button
//                Button(action: handleNextButton) {
//                    Text(animationStage >= 3 ? "Next" : "Get Started")
//                        .frame(width: 325, height: 15)
//                        .padding()
//                        .background(globalSettings.primaryYellowColor)
//                        .foregroundColor(.white)
//                        .cornerRadius(20)
//                        .font(.custom("Poppins-Bold", size: 16))
//                }
//                .padding(.bottom)
//            }
//        }
//    }
//    
//    private func handleBack() {
//        if animationStage >= 3 {
//            withAnimation {
//                animationStage = 0
//                bravoCoordinator.centerBravo()
//            }
//        } else {
//            onboardingCoordinator.moveToPrevious()
//        }
//    }
//    
//    private func handleNextButton() {
//        if animationStage < 3 {
//            animateToQuestions()
//        } else if validateForm() {
//            onboardingCoordinator.moveToNext()
//        }
//    }
//    
//    private func animateToQuestions() {
//        withAnimation(.spring(duration: 0.4)) {
//            bravoCoordinator.moveToSide()
//            animationStage = 1
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            withAnimation(.easeInOut(duration: 0.3)) {
//                animationStage = 2
//            }
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//            withAnimation(.easeInOut(duration: 0.3)) {
//                welcomeInput = 1
//                animationStage = 3
//            }
//        }
//    }
//    
//    private func validateForm() -> Bool {
//        if !firstName.isEmpty && 
//           !lastName.isEmpty && 
//           selectedAge != "Select your Age" && 
//           selectedLevel != "Select your Level" && 
//           selectedPosition != "Select your Position" {
//            
//            stateManager.updateWelcomeData(
//                firstName: firstName,
//                lastName: lastName,
//                ageRange: selectedAge,
//                level: selectedLevel,
//                position: selectedPosition
//            )
//            return true
//        }
//        return false
//    }
//}
//
//
//// MARK: - Preview
//struct WelcomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        let stateManager = OnboardingStateManager()
//        let navigator = NavigationCoordinator()
//        WelcomeView()
//            .environmentObject(stateManager)
//            .environmentObject(navigator)
//            .environmentObject(GlobalSettings())
//    }
//}
