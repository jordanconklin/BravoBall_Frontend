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
    
    private let layout = ResponsiveLayout.shared
    
    var body: some View {
        Button(action: {
            Haptic.light()
            showingFollowAlong = true
        }) {
            ZStack {
                // Background circle
                Circle()
                    .fill(editableDrill.isCompleted && editableDrill.totalSets == editableDrill.setsDone ?
                          appModel.globalSettings.primaryYellowColor : Color.white)
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 5)
                
                // Progress stroke circle
                Circle()
                    .stroke(
                        Color.gray.opacity(0.3),
                        lineWidth: 8
                    )
                    .frame(width: 85, height: 85)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(appModel.globalSettings.primaryYellowColor,
                                lineWidth: 8
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: progress)
                    )
                
                // Soccer icon
                Image(sessionModel.skillIconName(for: editableDrill.drill.skill))
                    .resizable()
                    .scaledToFit()
                    .frame(width: layout.isPad ? 44 : 40, height: layout.isPad ? 44 : 40)
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

#if DEBUG
struct FieldDrillCard_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
        // Create a mock drill and editable drill
        let drill = DrillModel(
            title: "One-Touch Pass",
            skill: "Passing",
            subSkills: ["short_passing"],
            sets: 3,
            reps: 10,
            duration: 15,
            description: "Practice quick one-touch passes with a partner or wall.",
            instructions: ["Pass and move"],
            tips: ["Keep your ankle locked", "Follow through"],
            equipment: ["Soccer ball", "Cones"],
            trainingStyle: "Medium Intensity",
            difficulty: "Beginner",
            videoUrl: "www.example.com"
        )
        let editableDrill = EditableDrillModel(
            drill: drill,
            setsDone: 1,
            totalSets: 3,
            totalReps: 10,
            totalDuration: 15,
            isCompleted: true
        )
        FieldDrillCard(
            appModel: appModel,
            sessionModel: sessionModel,
            editableDrill: .constant(editableDrill)
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif

