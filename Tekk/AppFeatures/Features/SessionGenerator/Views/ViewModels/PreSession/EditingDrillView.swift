//
//  EditingDrillView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/21/25.
//

import SwiftUI
import RiveRuntime
import AVKit

// TODO: make this code cleaner, and fix the values passed in for totalsets, totalreps, and totalduration

// MARK: Editing Drill VIew
struct EditingDrillView: View {
    
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Binding var editableDrill: EditableDrillModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewGeometry) var geometry
    
    @State private var showDrillDetailView: Bool = false
    @State private var editSets: String = ""
    @State private var editReps: String = ""
    @State private var editDuration: String = ""
    @FocusState private var isSetsFocused: Bool
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isDurationFocused: Bool
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "xmark")
                                .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        }
                    }
                    
                    Spacer()
                    
                    
                    // Progress header
                    Text("Edit Drill")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.black)
                        .padding(.leading, 60)
                    
                    Spacer()
                    
                    // How-to button
                    Button(action: {
                        showDrillDetailView = true
                        
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(Color.white)
                                .font(.system(size: 13, weight: .medium))
                            Text("Details")
                                .font(.custom("Poppins-Bold", size: 13))
                                .foregroundColor(.white)
                            
                        }
                        .padding(.horizontal,5)
                        .padding(.vertical, 5)

                        .background(appModel.globalSettings.primaryGrayColor)
                        .cornerRadius(12)
                            
                    }
                    
                }
                .padding(.vertical)
                
                if !editableDrill.drill.videoUrl.isEmpty, let videoUrl = URL(string: editableDrill.drill.videoUrl) {
                    VideoPlayer(player: AVPlayer(url: videoUrl))
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 25) {
                    HStack {
                        TextField("\(editableDrill.totalSets)", text: $editSets)
                            .keyboardType(.numberPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .focused($isSetsFocused)
                            .tint((appModel.globalSettings.primaryYellowColor))
                            .frame(maxWidth: 60)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 8)
                            .onChange(of: editSets) { _, newValue in
                                            let filtered = newValue.filter { $0.isNumber }
                                            if filtered.count > 2 {
                                                // Limit to 2 digits
                                                editSets = String(filtered.prefix(2))
                                            } else if filtered != newValue {
                                                // Only numbers allowed
                                                editSets = filtered
                                            }

                                        }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isSetsFocused ? appModel.globalSettings.primaryYellowColor : appModel.globalSettings.primaryLightGrayColor, lineWidth: 3)
                            )
                        Text("Sets")
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    }
                    HStack {
                        TextField("\(editableDrill.totalReps)", text: $editReps)
                            .keyboardType(.numberPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .focused($isRepsFocused)
                            .tint((appModel.globalSettings.primaryYellowColor))
                            .frame(maxWidth: 60)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 8)
                            .onChange(of: editSets) { _, newValue in
                                            let filtered = newValue.filter { $0.isNumber }
                                            if filtered.count > 2 {
                                                // Limit to 2 digits
                                                editSets = String(filtered.prefix(2))
                                            } else if filtered != newValue {
                                                // Only numbers allowed
                                                editSets = filtered
                                            }

                                        }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isRepsFocused ? appModel.globalSettings.primaryYellowColor : appModel.globalSettings.primaryLightGrayColor, lineWidth: 3)
                            )
                        Text("Reps")
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    }
                    HStack {
                        TextField("\(editableDrill.totalDuration)", text: $editDuration)
                            .keyboardType(.numberPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .focused($isDurationFocused)
                            .tint((appModel.globalSettings.primaryYellowColor))
                            .frame(maxWidth: 60)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 8)
                            .onChange(of: editSets) { _, newValue in
                                            let filtered = newValue.filter { $0.isNumber }
                                            if filtered.count > 2 {
                                                // Limit to 2 digits
                                                editSets = String(filtered.prefix(2))
                                            } else if filtered != newValue {
                                                // Only numbers allowed
                                                editSets = filtered
                                            }

                                        }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isDurationFocused ? appModel.globalSettings.primaryYellowColor : appModel.globalSettings.primaryLightGrayColor, lineWidth: 3)
                            )
                        Text("Minutes")
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    }
                    
                }
                .padding(.bottom, 100)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
        }
        .frame(width: geometry.size.width)
        .sheet(isPresented: $showDrillDetailView) {
            DrillDetailView(appModel: appModel, sessionModel: sessionModel, drill: editableDrill.drill)
        }
        
        // Checks if changes are made
        .safeAreaInset(edge: .bottom) {
            let validations = (
                sets: Int(editSets).map { $0 > 0 && $0 <= 99 } ?? false,
                reps: Int(editReps).map { $0 > 0 && $0 <= 99 } ?? false,
                duration: Int(editDuration).map { $0 > 0 && $0 <= 999 } ?? false
            )
            let setsValid = validations.sets
            let repsValid = validations.reps
            let durationValid = validations.duration
            
            

            
            Button(action: {

                if let sets = Int(editSets), setsValid {
                    editableDrill.totalSets = sets
                }
                if let reps = Int(editReps), repsValid {
                    editableDrill.totalReps = reps
                }
                if let duration = Int(editDuration), durationValid {
                    editableDrill.totalDuration = duration
                }
                
                appModel.viewState.showingDrillDetail = false
                
            }) {
                Text("Save Changes")
                    .font(.custom("Poppins-Bold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(setsValid || repsValid || durationValid ? appModel.globalSettings.primaryYellowColor : Color.gray.opacity(0.5))
                    .cornerRadius(12)
            }
            .disabled(!setsValid && !repsValid && !durationValid)
            .padding()
        }
    }
}

//#Preview {
//    let mockDrill = EditableDrillModel(
//        drill: DrillModel(
//            title: "Test Drill",
//            skill: "Passing",
//            sets: 2,
//            reps: 10,
//            duration: 15,
//            description: "Test description",
//            tips: ["Tip 1", "Tip 2"],
//            equipment: ["Ball"],
//            trainingStyle: "Medium Intensity",
//            difficulty: "Beginner"
//        ),
//        setsDone: 0,
//        totalSets: 2,
//        totalReps: 10,
//        totalDuration: 15,
//        isCompleted: false
//    )
//    
//    return EditingDrillView(
//        appModel: MainAppModel(),
//        sessionModel: SessionGeneratorModel(appModel: MainAppModel(), onboardingData: OnboardingModel.OnboardingData()),
//        editableDrill: .constant(mockDrill)
//    )
//}
