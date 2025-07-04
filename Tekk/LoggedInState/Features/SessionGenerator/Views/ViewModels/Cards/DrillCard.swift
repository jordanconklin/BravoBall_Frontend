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
                        appModel.viewState.showDrillOptions = true
                    }) {
                        // Right arrow
                        Image(systemName: "chevron.right")
                            .foregroundColor(globalSettings.primaryGrayColor)
                            .font(.system(size: layout.isPad ? 16 : 14, weight: .semibold))
                            .padding(.trailing, layout.isPad ? 24 : 16)
                    }
                   
                }
                .frame(maxWidth: layout.isPad ? 600 : 300)
            }
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
                    editableDrill: sessionModel.orderedSessionDrills[index]
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
}



// TODO: enum this


struct DrillOptions: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    
    @State private var selectedDrill: DrillModel? = nil
    let editableDrill: EditableDrillModel
    let globalSettings = GlobalSettings.shared
    
    
    // TODO: case enums for neatness and make this shared
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Button(action: {
                    Haptic.light()
                    
//                    withAnimation {
//                        appModel.viewState.showDrillOptions = false
//                    }
                    
                    selectedDrill = editableDrill.drill
                    
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(globalSettings.primaryDarkColor)
                        Text("Instructions")
                            .foregroundColor(globalSettings.primaryDarkColor)
                            .font(.custom("Poppins-Bold", size: 12))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .padding()
                
                Divider()
                
                Button(action: {
                    Haptic.light()
                    
                    withAnimation {
                        appModel.viewState.showDrillOptions = false
                    }
                    
                    
                    sessionModel.deleteDrillFromSession(drill: editableDrill)
                    
                    
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                            .foregroundColor(globalSettings.primaryDarkColor)
                        Text("Delete Drill")
                            .foregroundColor(globalSettings.primaryDarkColor)
                            .font(.custom("Poppins-Bold", size: 12))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .padding()
                
                
                Spacer()
            }
        }
            
            .padding(8)
            .background(Color.white)
            .frame(maxWidth: .infinity)
            .navigationDestination(item: $selectedDrill) { drill in
                DrillDetailView(appModel: appModel, sessionModel: sessionModel, drill: drill)
            }
            
        
    }
}
