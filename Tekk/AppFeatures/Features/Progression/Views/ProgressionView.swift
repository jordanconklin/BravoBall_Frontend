//
//  ProgressionView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/17/25.
//

import SwiftUI
import RiveRuntime

struct ProgressionView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let geometry: GeometryProxy
    
    var body: some View {
            VStack {
                // Progress header
                Text("Progress")
                    .font(.custom("Poppins-Bold", size: 25))
                    .foregroundColor(.white)
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 5) {
                        // Yellow section content
                        streakDisplay
                            .padding(.bottom, 20)
                        
                        // White section content with rounded top corners
                        ZStack {
                            RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                                .fill(Color.white)
                            
                            VStack(spacing: 5) {
                                CalendarView(appModel: appModel)
                                
                                // History display
                                HStack {
                                    VStack {
                                        Text(appModel.highestStreak == 1 ? "\(appModel.highestStreak)  day" : "\(appModel.highestStreak)  days")
                                            .font(.custom("Poppins-Bold", size: 30))
                                            .foregroundColor(appModel.globalSettings.primaryYellowColor)
                                        Text("Highest Streak")
                                            .font(.custom("Poppins-Bold", size: 16))
                                            .foregroundColor(appModel.globalSettings.primaryGrayColor)
                                    }
                                    .padding()
                                    
                                    VStack {
                                        Text("\(appModel.countOfFullyCompletedSessions)")
                                            .font(.custom("Poppins-Bold", size: 30))
                                            .foregroundColor(appModel.globalSettings.primaryYellowColor)
                                        Text("Sessions completed")
                                            .font(.custom("Poppins-Bold", size: 16))
                                            .foregroundColor(appModel.globalSettings.primaryGrayColor)
                                    }
                                    .padding()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 300) // TODO: fix bottom
                        }
                    }
                }
            }
            .background(appModel.globalSettings.primaryYellowColor)
            .sheet(isPresented: $appModel.showDrillResults) {
                DrillResultsView(appModel: appModel, sessionModel: sessionModel)
        }
    }
        
    // Streak display at the top
    private var streakDisplay: some View {
        ZStack {
            Color(appModel.globalSettings.primaryYellowColor)
            VStack {
                HStack {
                    Image("Streak_Flame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 90)
                    Text("\(appModel.currentStreak)")
                        .font(.custom("Poppins-Bold", size: 90))
                        .padding(.trailing, 20)
                        .foregroundColor(Color.white)
                }
                Text("Day Streak")
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
            }
            .padding()
        }
    }


}


//#Preview {
//    let mockAppModel = MainAppModel()
//    let mockSessionModel = SessionGeneratorModel(appModel: MainAppModel(), onboardingData: OnboardingModel.OnboardingData())
//    
//    return ProgressionView(appModel: mockAppModel, sessionModel: mockSessionModel)
//}
