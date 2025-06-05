//
//  DrillResultsView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/15/25.
//

import SwiftUI
import RiveRuntime


struct DrillResultsView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    
    @Environment(\.viewGeometry) var geometry
    @Environment(\.presentationMode) var presentationMode
    @State private var showScore: Bool = false
    
    
    
    var body: some View {
        ScrollView {
            LazyVStack {
                HStack {
                    backButton
                    Spacer()
                }
                .padding()
                
                Spacer ()
                
                if let session = appModel.selectedSession {
                    Text("\(formatDate(session.date))")
                        .padding()
                        .padding(.top, 20)
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)

                    Text("Score:")
                        .padding()
                        .font(.custom("Poppins-Bold", size: 30))
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    
                    
                    ZStack {
                        CircularScore(appModel: appModel, progress: Double(session.totalCompletedDrills) / Double(session.totalDrills))
                            .frame(width: 200, height: 200)
                        
                        Text("\(session.totalCompletedDrills) / \(session.totalDrills)")
                            .padding()
                            .font(.custom("Poppins-Bold", size: 40))
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .opacity(showScore ? 1 : 0)
                            .animation(.easeIn.delay(0.8), value: showScore)
                    }
                    .padding()
                    .padding(.bottom, 70)
                    .onAppear {
                        showScore = true
                    }
                    
                    Text("Drills:")
                        .padding()
                        .font(.custom("Poppins-Bold", size: 30))
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    

                    // MARK: Fix this
                    ForEach(session.drills, id: \.drill.id) { editableDrill in
                            ZStack {
                                if editableDrill.isCompleted {
                                    RiveViewModel(fileName: "Drill_Card_Complete").view()
                                        .frame(width: 330, height: 180)
                                } else {
                                    RiveViewModel(fileName: "Drill_Card_Incomplete").view()
                                        .frame(width: 330, height: 180)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                        
                                    Text("Drill: \(editableDrill.drill.title)")
                                            .font(.custom("Poppins-Bold", size: 18))
                                    Text("Skill: \(editableDrill.drill.skill)")
                                        HStack(spacing: 20) {
                                            Text("Duration: \(editableDrill.totalDuration)min")
                                            Text("Sets: \(editableDrill.drill.sets)")
                                            Text("Reps: \(editableDrill.drill.reps)")
                                        }
                                    Text("Equipment: \(editableDrill.drill.equipment.joined(separator: ", "))")
                                }
                                .padding()
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            }
                        }
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .frame(width: geometry.size.width)
    }

    
    private var backButton: some View {
        Button(action: {
            Haptic.light()
            appModel.showDrillResults = false
            appModel.selectedSession = nil
        }) {
            HStack {
                Image(systemName: "xmark")
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: date)
        }
}


