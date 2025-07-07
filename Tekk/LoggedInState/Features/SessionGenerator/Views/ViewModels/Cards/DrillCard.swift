//
//  DrillCard.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI
import RiveRuntime

// Mutable drill card

struct DrillCard: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let globalSettings = GlobalSettings.shared
    
    @Binding var editableDrill: EditableDrillModel
    @State private var showEditingDrillView = false
    let toastManager: ToastManager

    private let layout = ResponsiveLayout.shared
    
    
    var body: some View {
        
        let _ = print("DEBUG: DrillCard skill: '\(editableDrill.drill.skill)' -> Icon: '\(sessionModel.skillIconName(for: editableDrill.drill.skill))'")
        Button(action: {
            Haptic.light()
            sessionModel.selectedDrillForEditing = editableDrill
            showEditingDrillView = true
        }) {
            ZStack {
                // Background card
                RiveViewModel(fileName: "Drill_Card_Incomplete").view()
                    .frame(width: layout.isPad ? 640 : 320, height: layout.isPad ? 340 : 170)
                
                // Content container
                HStack(spacing: layout.isPad ? 20 : 12) {
                        // Left side content
                        HStack(spacing: layout.isPad ? 16 : 12) {
                            // Drag handle
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(globalSettings.primaryGrayColor)
                                .font(.system(size: layout.isPad ? 16 : 14))
                            
                            // Skill-specific icon
                            Image(sessionModel.skillIconName(for: editableDrill.drill.skill))
                                .resizable()
                                .scaledToFit()
                                .frame(width: layout.isPad ? 44 : 40, height: layout.isPad ? 44 : 40)
                                .padding(6)
                        }
                        .padding(.leading, layout.isPad ? 24 : 16)
                        
                        // Center content
                        VStack(alignment: .leading, spacing: layout.isPad ? 8 : 6) {
                            Text(editableDrill.drill.title)
                                .font(.custom("Poppins-Bold", size: layout.isPad ? 18 : 16))
                                .foregroundColor(globalSettings.primaryDarkColor)
                                .lineLimit(2)
                            Text("\(editableDrill.totalSets) sets - \(editableDrill.totalReps) reps - \(editableDrill.totalDuration) mins")
                                .font(.custom("Poppins-Bold", size: layout.isPad ? 13 : 11))
                                .foregroundColor(globalSettings.primaryGrayColor)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                        Button(action: {
                            sessionModel.selectedDrillForEditing = editableDrill
                            appModel.viewState.showDrillOptions = true
                        }) {
                            // Right arrow
                            Image(systemName: "ellipsis")
                                .foregroundColor(globalSettings.primaryGrayColor)
                                .font(.system(size: layout.isPad ? 16 : 14, weight: .semibold))
                                .padding(10)
                                .padding(.trailing, layout.isPad ? 24 : 16)
                        }
                    }
                    
                    
                    
                   
                }
                .frame(maxWidth: layout.isPad ? 600 : 300)
            }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showEditingDrillView) {
            if let selectedDrill = sessionModel.selectedDrillForEditing,
               let index = sessionModel.orderedSessionDrills.firstIndex(where: {$0.drill.id == selectedDrill.drill.id}) {
                EditingDrillView(
                    appModel: appModel,
                    sessionModel: sessionModel,
                    editableDrill: $sessionModel.orderedSessionDrills[index])
            }
        }
        .sheet(isPresented: $appModel.viewState.showDrillOptions) {
            if let selectedDrill = sessionModel.selectedDrillForEditing,
               let index = sessionModel.orderedSessionDrills.firstIndex(where: {$0.drill.id == selectedDrill.drill.id}) {
                DrillOptions(
                    appModel: appModel,
                    sessionModel: sessionModel,
                    editableDrill: sessionModel.orderedSessionDrills[index],
                    toastManager: toastManager
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
}

// Reusable options sheet structure
struct OptionsSheet<Content: View>: View {
    let title: String
    let content: Content
    let onDismiss: () -> Void
    
    init(title: String, onDismiss: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.title = title
        self.onDismiss = onDismiss
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Header
            HStack {
                Spacer()
                Text(title)
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(GlobalSettings.shared.primaryDarkColor)
                
                Spacer()
                Button(action: {
                    Haptic.light()
                    withAnimation(.spring(dampingFraction: 0.7)) {
                        onDismiss()
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(GlobalSettings.shared.primaryGrayColor)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            content
            
            Spacer()
        }
        .padding(8)
        .background(Color.white)
        .frame(maxWidth: .infinity)
    }
}

// Reusable option button
struct OptionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(GlobalSettings.shared.primaryDarkColor)
                Text(title)
                    .foregroundColor(GlobalSettings.shared.primaryDarkColor)
                    .font(.custom("Poppins-Bold", size: 12))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

// TODO: enum this


struct DrillOptions: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    
    let editableDrill: EditableDrillModel
    let globalSettings = GlobalSettings.shared
    let toastManager: ToastManager
    
    
    // TODO: case enums for neatness and make this shared
    
    var body: some View {
        OptionsSheet(
            title: "Drill Options",
            onDismiss: {
                appModel.viewState.showDrillOptions = false
            }
        ) {
            VStack(alignment: .leading, spacing: 5) {
                OptionButton(
                    icon: "questionmark.circle.fill",
                    title: "Instructions"
                ) {
                    Haptic.light()
                    
                    withAnimation {
                        appModel.viewState.showDrillOptions = false
                    }
                    
                    // Add a small delay to ensure the sheet is fully dismissed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        sessionModel.selectedDrill = editableDrill.drill
                    }
                }
                
                Divider()
                
                OptionButton(
                    icon: "trash",
                    title: "Delete Drill"
                ) {
                    Haptic.light()
                    
                    withAnimation {
                        appModel.viewState.showDrillOptions = false
                    }
                    
                    sessionModel.deleteDrillFromSession(drill: editableDrill)
                    toastManager.showToast(.success("Drill deleted"))
                }
            }
        }
    }
}
