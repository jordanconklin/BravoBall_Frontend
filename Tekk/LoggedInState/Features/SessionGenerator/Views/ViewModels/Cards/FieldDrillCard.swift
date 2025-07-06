//
//  FieldDrillCircleButton.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI
import RiveRuntime

struct FieldDrillCircleButton: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Binding var editableDrill: EditableDrillModel
    let globalSettings = GlobalSettings.shared
    
    @State private var showingFollowAlong: Bool = false
    
    private let layout = ResponsiveLayout.shared
    
    var body: some View {


            ZStack {
                
                mainCircle

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
                            .stroke(globalSettings.primaryYellowColor,
                                lineWidth: 8
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: progress)
                    )
                    .offset(x: 0, y: 3)
                    .opacity(editableDrill.setsDone > 0 || editableDrill.isCompleted ? 1.0 : 0.0)
                    .onAppear {
                        print("DEBUG: FieldDrillCircleButton appeared for '\(editableDrill.drill.title)' with setsDone=\(editableDrill.setsDone), isCompleted=\(editableDrill.isCompleted)")
                    }
                
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
    
    var mainCircle: some View {
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
        let progressValue = Double(editableDrill.setsDone) / Double(editableDrill.totalSets)
        print("DEBUG: Progress calculation for '\(editableDrill.drill.title)': setsDone=\(editableDrill.setsDone), totalSets=\(editableDrill.totalSets), progress=\(progressValue)")
        return progressValue
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
            return globalSettings.primaryYellowColor
        case .inProgress:
            return Color.white
        case .noProgress:
            return globalSettings.primaryLightGrayColor
        }
    }
    
    private func backCircleColor(for state: CardColorState) -> Color {
        switch state {
        case .complete:
            return globalSettings.primaryDarkYellowColor
        case .inProgress:
            return globalSettings.primaryLightGrayColor
        case .noProgress:
            return Color(hex:"b5b5b5")
        }
    }
    
    
}

