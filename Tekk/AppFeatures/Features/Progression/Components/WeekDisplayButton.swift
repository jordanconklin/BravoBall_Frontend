///
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
    let session: CompletedSession?
    
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
                    ZStack {
                        RiveViewModel(fileName: "Day_Null").view()
                            .frame(width: 60, height: 60)
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                        
                        if score == 1.0 {
                            ZStack {
                                RiveViewModel(fileName: "Paw_Yellow").view()
                                    .frame(width: 40, height: 40)
                                Text(text)
                                    .font(.custom("Poppins-Bold", size: 22))
                                    .foregroundColor(Color.white)
                            }
                        } else {
                            ZStack {
                                RiveViewModel(fileName: "Paw_Gray").view()
                                    .frame(width: 40, height: 40)
                                Text(text)
                                    .font(.custom("Poppins-Bold", size: 22))
                                    .foregroundColor(Color.white)
                            }
                        }
                    }
                }
                
            } else {
                RiveViewModel(fileName: "Day_Null").view()
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)
                    .clipped()
                
                if highlightedDay {
                    Text(text)
                        .font(.custom("Poppins-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 38, height: 38)
                        )
                } else {
                    Text(text)
                        .font(.custom("Poppins-Bold", size: 25))
                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                }
            }
        }
    }
}


