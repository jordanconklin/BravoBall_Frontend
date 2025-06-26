//
//  WeekDisplayButton.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/12/25.
//

import SwiftUI
import RiveRuntime


struct WeekDisplayButton: View {
    @ObservedObject var appModel: MainAppModel
    
    let text: String
    let date: Date
    let highlightedDay: Bool
    let session: MainAppModel.CompletedSession?
    
    var body: some View {
        
        ZStack {
        
            if let session = session {
                
                // Convert to float types, get score
                let score = Double(session.totalCompletedDrills) / Double(session.totalDrills)
                
                Button(action: {
                        // Lets DrillResultsView access session
                        appModel.selectedSession = session
                        appModel.showDrillResults = true
                }) {
                    if score == 1.0 {
                        ZStack {
                            // High score = green
                            RiveViewModel(fileName: "Day_High_Score").view()
                                .frame(width: 60, height: 60)
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                            
                            Text(text)
                                .font(.custom("Poppins-Bold", size: 30))
                                .foregroundColor(appModel.globalSettings.primaryGrayColor)
                        }
                    } else if score < 1 && score > 0.0 {
                        ZStack {
                            // Medium score = yellow
                            RiveViewModel(fileName: "Day_Medium_Score").view()
                                .frame(width: 60, height: 60)
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                            
                            Text(text)
                                .font(.custom("Poppins-Bold", size: 30))
                                .foregroundColor(appModel.globalSettings.primaryGrayColor)
                        }
                    } else {
                        ZStack {
                            // Low score = Red
                            RiveViewModel(fileName: "Day_Low_Score").view()
                                .frame(width: 60, height: 60)
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                            
                            Text(text)
                                .font(.custom("Poppins-Bold", size: 30))
                                .foregroundColor(appModel.globalSettings.primaryGrayColor)
                        }
                    }
                }
                
            } else {
//                RiveViewModel(fileName: "Day_Null").view()
//                    .frame(width: 60, height: 60)
//                    .aspectRatio(contentMode: .fit)
//                    .clipped()
                
                if highlightedDay {
                    Text(text)
                        .font(.custom("Poppins-Bold", size: 30))
                        .foregroundColor(Color.white)
                        .background(
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 42, height: 42)
                        )
                } else {
                    Text(text)
                        .font(.custom("Poppins-Bold", size: 30))
                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                }
            }
        }
    }
}


#Preview {
    let mockAppModel = MainAppModel()
    
    // Create mock drills
        let mockDrills = [
            MainAppModel.DrillData(
                name: "Test Drill 1",
                skill: "Dribbling",
                duration: 20,
                sets: 4,
                reps: 8,
                equipment: ["Ball"],
                isCompleted: true
            ),
            MainAppModel.DrillData(
                name: "Test Drill 2",
                skill: "Shooting",
                duration: 15,
                sets: 3,
                reps: 10,
                equipment: ["Ball", "Goal"],
                isCompleted: false
            )
        ]
        
        // Create mock session
        let mockSession = MainAppModel.CompletedSession(
            date: Date(),
            drills: mockDrills,
            totalCompletedDrills: 1,  // One drill completed
            totalDrills: 2           // Out of two total drills
        )
    
    return WeekDisplayButton(
        appModel: mockAppModel,
        text: "34",
        date: Date(),
        highlightedDay: true,
        session: mockSession
    )
}
