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
    
    @Binding var editableDrill: EditableDrillModel
    private let layout = ResponsiveLayout.shared
    
    var body: some View {
        Button(action: {
            sessionModel.selectedDrillForEditing = editableDrill
            appModel.viewState.showingDrillDetail = true
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
                            .foregroundColor(appModel.globalSettings.primaryGrayColor)
                            .font(.system(size: layout.isPad ? 16 : 14))
                        
                        // Soccer icon
                        Image(systemName: "figure.soccer")
                            .font(.system(size: layout.isPad ? 28 : 24))
                            .padding(layout.isPad ? 12 : 8)
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.leading, layout.isPad ? 24 : 16)
                    
                    // Center content
                    VStack(alignment: .leading, spacing: layout.isPad ? 8 : 6) {
                        Text(editableDrill.drill.title)
                            .font(.custom("Poppins-Bold", size: layout.isPad ? 18 : 16))
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .lineLimit(2)
                        Text("\(editableDrill.totalSets) sets - \(editableDrill.totalReps) reps - \(editableDrill.totalDuration)")
                            .font(.custom("Poppins-Bold", size: layout.isPad ? 16 : 14))
                            .foregroundColor(appModel.globalSettings.primaryGrayColor)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Right arrow
                    Image(systemName: "chevron.right")
                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                        .font(.system(size: layout.isPad ? 16 : 14, weight: .semibold))
                        .padding(.trailing, layout.isPad ? 24 : 16)
                }
                .frame(maxWidth: layout.isPad ? 600 : 300)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $appModel.viewState.showingDrillDetail) {
            if let selectedDrill = sessionModel.selectedDrillForEditing,
               let index = sessionModel.orderedSessionDrills.firstIndex(where: {$0.drill.id == selectedDrill.drill.id}) {
                EditingDrillView(
                    appModel: appModel,
                    sessionModel: sessionModel,
                    editableDrill: $sessionModel.orderedSessionDrills[index])
            }
        }
    }
}
