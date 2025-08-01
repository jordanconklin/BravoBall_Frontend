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
    let globalSettings = GlobalSettings.shared
    
    
    var body: some View {
        
        ZStack {
            
            // Sky background color
            Color(globalSettings.primaryYellowColor)
                .ignoresSafeArea()
            
            VStack {
                Text(sessionModel.allSessionSetsNotComplete() ? "Your session has ended." : "You've completed your session!")
                    .foregroundColor(Color.white)
                    .font(.custom("Poppins-Bold", size: 20))
                    .padding()
                
                RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 1").view()
                    .frame(width: 200, height: 200)
                
                VStack {
                    HStack {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
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
                if sessionModel.allSessionSetsNotComplete() || appModel.allCompletedSessions.count(where: {
                    Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .day)
                }) != 1 {
                    // Note about streak progress
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(globalSettings.primaryDarkColor)
                        Text("Note: Streak progress only increases on a new day and when you complete all the drills in your session.")
                            .font(.custom("Poppins-Bold", size: 14))
                            .foregroundColor(globalSettings.primaryDarkColor)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                PrimaryButton(
                    title: "Back to home page",
                    action: {
                        Haptic.light()
                        resetSessionState()
                    },
                    frontColor: globalSettings.primaryGreenColor,
                    backColor: globalSettings.primaryDarkGreenColor,
                    textColor: Color.white,
                    textSize: 18,
                    width: .infinity,
                    height: 50,
                    disabled: false
                        
                )
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
        sessionModel: SessionGeneratorModel()
    )
}
