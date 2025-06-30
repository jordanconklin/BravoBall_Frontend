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
    
    @State private var selectedDrill: DrillModel? = nil
    @State private var editSets: String = ""
    @State private var editReps: String = ""
    @State private var editDuration: String = ""
    @FocusState private var isSetsFocused: Bool
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isDurationFocused: Bool
    @State private var showInfoSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: {
                        Haptic.light()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "xmark")
                                .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        }
                    }
                    
                    Spacer()
                    
                    // Edit drill header
                    Text("Edit Drill")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.black)
                        .padding(.leading, 70)
                    
                    Spacer()
                    
                    // How-to button
                    Button(action: {
                        Haptic.light()
                        selectedDrill = editableDrill.drill
                        
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(Color.white)
                                .font(.system(size: 13, weight: .medium))
                            Text("Details")
                                .font(.custom("Poppins-Bold", size: 14))
                                .foregroundColor(.white)
                            
                        }
                        .padding(.horizontal,10)
                        .padding(.vertical, 8)

                        .background(appModel.globalSettings.primaryGrayColor)
                        .cornerRadius(12)
                            
                    }
                    
                }
                .padding(.vertical)
                
                if !editableDrill.drill.videoUrl.isEmpty, let videoUrl = URL(string: editableDrill.drill.videoUrl) {
                    CustomVideoPlayer(videoURL: videoUrl)
                    // Info button below video, aligned right, with more spacing and larger icon
                    HStack {
                        Spacer()
                        Button(action: {
                            Haptic.light()
                            showInfoSheet = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(appModel.globalSettings.primaryGrayColor)
                                .font(.system(size: 26, weight: .regular))
                        }
                        .accessibilityLabel("About Editing Drill")
                        .padding(.trailing, 12)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 8)
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
                
                savedChangesButton
                
            }
            .padding(.horizontal, 20)
            .navigationDestination(item: $selectedDrill) { drill in
                DrillDetailView(appModel: appModel, sessionModel: sessionModel, drill: drill)
            }
            
        }
        .frame(width: geometry.size.width)
        
        // Info popup sheet for editing help
        .sheet(isPresented: $showInfoSheet) {
            InfoPopupView(
                title: "Editing Drill Details",
                description: "You can customize the number of sets, reps, and minutes for this drill.\n\nSets: How many times you repeat the drill.\nReps: How many repetitions per set.\nMinutes: Duration for each set.\n\nAdjust these values to match your training needs, then tap 'Save Changes' to update your session.",
                onClose: { showInfoSheet = false }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var savedChangesButton: some View {
        let validations = (
            sets: Int(editSets).map { $0 > 0 && $0 <= 99 } ?? false,
            reps: Int(editReps).map { $0 > 0 && $0 <= 99 } ?? false,
            duration: Int(editDuration).map { $0 > 0 && $0 <= 999 } ?? false
        )
        let setsValid = validations.sets
        let repsValid = validations.reps
        let durationValid = validations.duration
        
        return PrimaryButton(
            title: "Save Changes",
            action: {
                Haptic.light()

                if let sets = Int(editSets), setsValid {
                    editableDrill.totalSets = sets
                }
                if let reps = Int(editReps), repsValid {
                    editableDrill.totalReps = reps
                }
                if let duration = Int(editDuration), durationValid {
                    editableDrill.totalDuration = duration
                }
                
                dismiss()
            },
            frontColor: appModel.globalSettings.primaryYellowColor,
            backColor: appModel.globalSettings.primaryDarkYellowColor,
            textColor: Color.white,
            textSize: 18,
            width: .infinity,
            height: 50,
            disabled: !setsValid && !repsValid && !durationValid
                
        )
        .padding()
    }
}

//#if DEBUG
//struct EditingDrillView_Previews: PreviewProvider {
//    static var previews: some View {
//        let appModel = MainAppModel()
//        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
//        let mockDrill = EditableDrillModel(
//            drill: DrillModel(
//                title: "Test Drill",
//                skill: "Passing",
//                subSkills: ["short_passing"],
//                sets: 3,
//                reps: 10,
//                duration: 15,
//                description: "Practice short passing technique.",
//                instructions: ["Pass the ball back and forth."],
//                tips: ["Keep your ankle locked."],
//                equipment: ["Soccer ball"],
//                trainingStyle: "Medium Intensity",
//                difficulty: "Beginner",
//                videoUrl: "https://bravoball-drills.s3.us-east-2.amazonaws.com/first-touch-drills/freestyle-juggling-with-wall.mp4"
//            ),
//            setsDone: 0,
//            totalSets: 3,
//            totalReps: 10,
//            totalDuration: 15,
//            isCompleted: false
//        )
//        return EditingDrillView(
//            appModel: appModel,
//            sessionModel: sessionModel,
//            editableDrill: .constant(mockDrill)
//        )
//        .previewLayout(.sizeThatFits)
//        .padding()
//    }
//}
//#endif
