//
//  FieldDrillCard.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI
import RiveRuntime

struct FieldDrillCard: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Binding var editableDrill: EditableDrillModel
    @State private var showingFollowAlong: Bool = false
    
    var body: some View {
        Button(action: {
            Haptic.light()
            showingFollowAlong = true
        }) {
            ZStack {
                // Progress stroke rectangle
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        Color.gray.opacity(0.3),
                        lineWidth: 7
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .trim(from: 0, to: progress)
                            .stroke(
                                appModel.globalSettings.primaryYellowColor,
                                lineWidth: 7
                            )
                            .animation(.linear, value: progress)
                    )
                    .frame(width: 110, height: 60)
                
                // Drill card
                ZStack {
                    if editableDrill.isCompleted && editableDrill.totalSets == editableDrill.setsDone {
                        RiveViewModel(fileName: "Drill_Card_Complete").view()
                        .frame(width: 100, height: 50)
                    } else {
                        RiveViewModel(fileName: "Drill_Card_Incomplete").view()
                        .frame(width: 100, height: 50)
                    }
                    Image(systemName: "figure.soccer")
                        .font(.system(size: 20))
                        .padding()
                        .foregroundColor(editableDrill.isCompleted && editableDrill.totalSets == editableDrill.setsDone ? Color.white : appModel.globalSettings.primaryDarkColor)

                }
            }
            
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(editableDrill.isCompleted || isCurrentDrill() ? 1.0 : 0.5)
        .disabled(!editableDrill.isCompleted && !isCurrentDrill())
        .fullScreenCover(isPresented: $showingFollowAlong) {
            DrillFollowAlongView(
                appModel: appModel,
                sessionModel: sessionModel,
                editableDrill: $editableDrill
                )
        }
    }
    
    var progress: Double {
            Double(editableDrill.setsDone) / Double(editableDrill.totalSets)
        }
    
    private func isCurrentDrill() -> Bool {
        if let firstIncompleteDrill = sessionModel.orderedSessionDrills.first(where: { !$0.isCompleted }) {
            return firstIncompleteDrill.drill.id == editableDrill.drill.id
        }
        return false
    }
}
