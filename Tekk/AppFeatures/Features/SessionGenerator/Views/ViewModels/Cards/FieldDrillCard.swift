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


            ZStack {
                
                cardCircle

                // Progress stroke circle
                Circle()
                    .stroke(
                        Color.gray.opacity(0.3),
                        lineWidth: 8
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(appModel.globalSettings.primaryYellowColor,
                                lineWidth: 8
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: progress)
                    )
                    .offset(x: 0, y: 3)
                    .opacity(!editableDrill.isCompleted && !isCurrentDrill() ? 0.0 : 1.0)
                
            }
            .fullScreenCover(isPresented: $showingFollowAlong) {
                DrillFollowAlongView(
                    appModel: appModel,
                    sessionModel: sessionModel,
                    editableDrill: $editableDrill
                    )
            }
        
        
    }
    
    private func drillComplete() -> Bool {
        return editableDrill.isCompleted && editableDrill.totalSets == editableDrill.setsDone
    }
    
    var cardCircle: some View {
        let state: CardColorState
        if drillComplete() {
            state = .complete
        } else if !editableDrill.isCompleted && isCurrentDrill() {
            state = .inProgress
        } else if !editableDrill.isCompleted && !isCurrentDrill() {
            state = .noProgress
        } else {
            state = .inProgress
        }
        return CircleButton(
            action: {
                Haptic.light()
                showingFollowAlong = true
            },
            frontColor: frontCircleColor(for: state),
            backColor: backCircleColor(for: state),
            width: 75,
            height: 75,
            disabled: !editableDrill.isCompleted && !isCurrentDrill(),
            pressedOffset: 6
        ) {
            Image(sessionModel.skillIconName(for: editableDrill.drill.skill))
                .resizable()
                .scaledToFit()
                .frame(width: layout.isPad ? 44 : 40, height: layout.isPad ? 44 : 40)
                .opacity(!editableDrill.isCompleted && !isCurrentDrill() ? 0.5 : 1.0)
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
    
    
    private enum CardColorState {
        case complete
        case inProgress
        case noProgress
    }
    
    private func frontCircleColor(for state: CardColorState) -> Color {
        switch state {
        case .complete:
            return appModel.globalSettings.primaryYellowColor
        case .inProgress:
            return Color.white
        case .noProgress:
            return appModel.globalSettings.primaryLightGrayColor
        }
    }
    
    private func backCircleColor(for state: CardColorState) -> Color {
        switch state {
        case .complete:
            return appModel.globalSettings.primaryDarkYellowColor
        case .inProgress:
            return appModel.globalSettings.primaryLightGrayColor
        case .noProgress:
            return Color(hex:"b5b5b5")
        }
    }
    
    
}

//#if DEBUG
//struct FieldDrillCard_Previews: PreviewProvider {
//    static var previews: some View {
//        let appModel = MainAppModel()
//        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
//        // Create a mock drill and editable drill
//        let drill = DrillModel(
//            title: "One-Touch Pass",
//            skill: "Passing",
//            subSkills: ["short_passing"],
//            sets: 3,
//            reps: 10,
//            duration: 15,
//            description: "Practice quick one-touch passes with a partner or wall.",
//            instructions: ["Pass and move"],
//            tips: ["Keep your ankle locked", "Follow through"],
//            equipment: ["Soccer ball", "Cones"],
//            trainingStyle: "Medium Intensity",
//            difficulty: "Beginner",
//            videoUrl: "www.example.com"
//        )
//        let editableDrill = EditableDrillModel(
//            drill: drill,
//            setsDone: 0,
//            totalSets: 3,
//            totalReps: 10,
//            totalDuration: 15,
//            isCompleted: true
//        )
//        FieldDrillCard(
//            appModel: appModel,
//            sessionModel: sessionModel,
//            editableDrill: .constant(editableDrill)
//        )
//        .previewLayout(.sizeThatFits)
//        .padding()
//    }
//}
//#endif
//
