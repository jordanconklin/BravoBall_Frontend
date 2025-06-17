//
//  SessionCompleteView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/15/25.
//

import SwiftUI
import RiveRuntime

struct SessionCompleteView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    
    var body: some View {
        
        ZStack {
            
            // Sky background color
            Color(appModel.globalSettings.primaryYellowColor)
                .ignoresSafeArea()
            
            VStack {
                Text(sessionModel.allSessionSetsNotComplete() ? "Your session has ended, but it was incomplete." : "You've completed your session!")
                    .foregroundColor(Color.white)
                    .font(.custom("Poppins-Bold", size: 20))
                    .padding()
                
                RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 1").view()
                    .frame(width: 200, height: 200)
                
                VStack {
                    HStack {
                        Image("Streak_Flame")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 90)
                        Text("\(appModel.currentStreak)")
                            .font(.custom("Poppins-Bold", size: 90))
                            .foregroundColor(Color.white)
                        if appModel.allCompletedSessions.count(where: {
                            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .day)
                        }) == 1  {
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 30, height: 30)
                                Text("+ 1")
                                    .font(.custom("Poppins-Bold", size: 15))
                                    .foregroundColor(Color.white)
                            }
                        }

                    }
                    Text("Day Streak")
                        .font(.custom("Poppins-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                }
                .padding()
                
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 25) {
                if sessionModel.allSessionSetsNotComplete() {
                    // Note about streak progress
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        Text("Note: your streak progress only increases when you complete all the drills in your session")
                            .font(.custom("Poppins-Bold", size: 14))
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Button(action: {
                    Haptic.light()
                    resetSessionState()
                }) {
                    Text("Back to home page")
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(appModel.globalSettings.primaryGreenColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
    }
    
    // Keep ordered session drills populated
    private func resetSessionState() {
        
        appModel.viewState.showSessionComplete = false
        
        // resets progress of drills in session
        for index in sessionModel.orderedSessionDrills.indices {
                sessionModel.orderedSessionDrills[index].setsDone = 0
                sessionModel.orderedSessionDrills[index].isCompleted = false
            }
    }
}


#Preview("Session Complete") {
    SessionCompleteView(
        appModel: MainAppModel(),
        sessionModel: SessionGeneratorModel(appModel: MainAppModel(), onboardingData: .init())
    )
}
