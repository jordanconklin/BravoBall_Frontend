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
    let globalSettings = GlobalSettings.shared
    
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
                                .foregroundColor(globalSettings.primaryDarkColor)
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

                        .background(globalSettings.primaryGrayColor)
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
                                .foregroundColor(globalSettings.primaryGrayColor)
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
                            .foregroundColor(globalSettings.primaryDarkColor)
                            .focused($isSetsFocused)
                            .tint((globalSettings.primaryYellowColor))
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
                                    .stroke(isSetsFocused ? globalSettings.primaryYellowColor : globalSettings.primaryLightGrayColor, lineWidth: 3)
                            )
                        Text("Sets")
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(globalSettings.primaryDarkColor)
                    }
                    HStack {
                        TextField("\(editableDrill.totalReps)", text: $editReps)
                            .keyboardType(.numberPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(globalSettings.primaryDarkColor)
                            .focused($isRepsFocused)
                            .tint((globalSettings.primaryYellowColor))
                            .frame(maxWidth: 60)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 8)
                            .onChange(of: editReps) { _, newValue in
                                            let filtered = newValue.filter { $0.isNumber }
                                            if filtered.count > 2 {
                                                // Limit to 2 digits
                                                editReps = String(filtered.prefix(2))
                                            } else if filtered != newValue {
                                                // Only numbers allowed
                                                editReps = filtered
                                            }

                                        }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isRepsFocused ? globalSettings.primaryYellowColor : globalSettings.primaryLightGrayColor, lineWidth: 3)
                            )
                        Text("Reps")
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(globalSettings.primaryDarkColor)
                    }
                    HStack {
                        TextField("\(editableDrill.totalDuration)", text: $editDuration)
                            .keyboardType(.numberPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(globalSettings.primaryDarkColor)
                            .focused($isDurationFocused)
                            .tint((globalSettings.primaryYellowColor))
                            .frame(maxWidth: 60)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 8)
                            .onChange(of: editDuration) { _, newValue in
                                            let filtered = newValue.filter { $0.isNumber }
                                            if filtered.count > 2 {
                                                // Limit to 2 digits
                                                editDuration = String(filtered.prefix(2))
                                            } else if filtered != newValue {
                                                // Only numbers allowed
                                                editDuration = filtered
                                            }

                                        }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isDurationFocused ? globalSettings.primaryYellowColor : globalSettings.primaryLightGrayColor, lineWidth: 3)
                            )
                        Text("Minutes")
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(globalSettings.primaryDarkColor)
                    }
                    
                }
                .padding(.bottom, 100)
                
                Spacer()
                
                saveChangesButton
                
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
    
    private var saveChangesButton: some View {
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
            frontColor: globalSettings.primaryYellowColor,
            backColor: globalSettings.primaryDarkYellowColor,
            textColor: Color.white,
            textSize: 18,
            width: .infinity,
            height: 50,
            disabled: !setsValid && !repsValid && !durationValid
                
        )
        .padding()
    }
}
