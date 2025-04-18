//
//  ByTypeView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

//import SwiftUI
//
//struct ByTypeView: View {
//    @ObservedObject var appModel: MainAppModel
//    @ObservedObject var sessionModel: SessionGeneratorModel
//    
//    var body: some View {
//        ZStack {
//            ScrollView(showsIndicators: false) {
//                LazyVStack(spacing: 15) {
//                    Text("Skill")
//                        .padding()
//                    VStack(spacing: 10) {
//                        ForEach(SkillType.allCases, id: \.self) { skill in
//                            SelectionButton(
//                                title: skill.rawValue,
//                                isSelected: appModel.selectedSkillButton == skill
//                            ){
//                                appModel.selectedSkillButton = skill
//                            }
//                        }
//                        
//                    }
//                    Spacer()
//                    
//                    Text("Training Style")
//                        .padding()
//                    VStack(spacing: 10) {
//                        ForEach(TrainingStyleType.allCases, id: \.self) { trainingStyle in
//                            SelectionButton(
//                                title: ("\(trainingStyle.rawValue) Intensity"),
//                                isSelected: appModel.selectedTrainingStyle == trainingStyle
//                            ){
//                                appModel.selectedTrainingStyle = trainingStyle
//                            }
//                        }
//                    }
//                    
//                    Spacer()
//                    
//                    Text("Difficulty")
//                        .padding()
//                    VStack(spacing: 10) {
//                        ForEach(DifficultyType.allCases, id: \.self) { difficulty in
//                            SelectionButton(
//                                title: difficulty.rawValue,
//                                isSelected: appModel.selectedDifficulty == difficulty
//                            ){
//                                appModel.selectedDifficulty = difficulty
//                            }
//                        }
//                        
//                    }
//                    Spacer()
//                }
//                .padding(.top, 30)
//                .frame(maxWidth: .infinity)
//            }
//            
//            // TODO: enum this
//            
//            if let selectedSkillButton = appModel.selectedSkillButton {
//                SpecificDrillsView(
//                    appModel: appModel,
//                    sessionModel: sessionModel,
//                    geometry: geometry,
//                    type: selectedSkillButton.rawValue,
//                    dismiss: {appModel.selectedSkillButton = nil})
//            }
//            
//            if let selectedTrainingStyle = appModel.selectedTrainingStyle {
//                SpecificDrillsView(
//                    appModel: appModel,
//                    sessionModel: sessionModel,
//                    type: selectedTrainingStyle.rawValue,
//                    dismiss: {appModel.selectedTrainingStyle = nil})
//            }
//            
//            if let selectedDifficulty = appModel.selectedDifficulty {
//                SpecificDrillsView(
//                    appModel: appModel,
//                    sessionModel: sessionModel,
//                    type: selectedDifficulty.rawValue,
//                    dismiss: {appModel.selectedDifficulty = nil})
//            }
//
//        }
//    }
//}
