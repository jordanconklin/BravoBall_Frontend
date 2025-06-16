//
//  GeneratedDrillsSection.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI
import RiveRuntime

struct GeneratedDrillsSection: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    
    private let layout = ResponsiveLayout.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Main vertical stack for the drills section
        LazyVStack(alignment: .center, spacing: layout.standardSpacing) {
            HStack {
                
                Spacer()
                
                // Toggle delete mode for drills
                Button(action: {
                    Haptic.light()
                    withAnimation(.spring(dampingFraction: 0.7)) {
                        appModel.viewState.showSessionDeleteButtons.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(appModel.globalSettings.primaryLightGrayColor)
                            .frame(width: 30, height: 30)
                            .offset(x: 0, y: 3)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "trash")
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .disabled(sessionModel.orderedSessionDrills.isEmpty)
                
                // Add drill button (opens drill search sheet)
                Button(action: {
                    Haptic.light()
                    appModel.viewState.showSearchDrills = true
                }) {
                    RiveViewModel(fileName: "Plus_Button").view()
                        .frame(width: 30, height: 30)
                }
            }
 
            // Show loading indicator if loading
            if sessionModel.isLoadingDrills {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .tint(appModel.globalSettings.primaryYellowColor)
                    
                    Text("Loading drills...")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 50)
                .transition(.opacity)
            }
            // Show placeholder if no drills are selected and not loading
            else if sessionModel.orderedSessionDrills.isEmpty {
                Spacer()
                HStack {
                    Image(systemName: "lock.fill")
                        .frame(width: 50, height: 50)
                        .foregroundColor(appModel.globalSettings.primaryLightGrayColor)
                    Text("Session will show up here once skills or filters are chosen.")
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(appModel.globalSettings.primaryLightGrayColor)
                }
                .padding(30)
            } else {
                // List each drill card in the session
                ForEach($sessionModel.orderedSessionDrills, id: \.drill.id) { $editableDrill in
                    HStack {
                        // Show delete button if in delete mode
                        if appModel.viewState.showSessionDeleteButtons {
                            Button(action: {
                                Haptic.light()
                                sessionModel.deleteDrillFromSession(drill: editableDrill)
                                if sessionModel.orderedSessionDrills.isEmpty {
                                    appModel.viewState.showSessionDeleteButtons = false
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 20, height: 20)
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 10, height: 2)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.leading)
                        }
                        
                        // Drill card with drag-and-drop support
                        DrillCard(
                            appModel: appModel,
                            sessionModel: sessionModel,
                            editableDrill: $editableDrill
                        )
                        .draggable(editableDrill.drill.title) {
                            DrillCard(
                                appModel: appModel,
                                sessionModel: sessionModel,
                                editableDrill: $editableDrill
                            )
                        }
                        .dropDestination(for: String.self) { items, location in
                            // Handle drag-and-drop reordering
                            guard let sourceTitle = items.first,
                                  let sourceIndex = sessionModel.orderedSessionDrills.firstIndex(where: { $0.drill.title == sourceTitle }),
                                  let destinationIndex = sessionModel.orderedSessionDrills.firstIndex(where: { $0.drill.title == editableDrill.drill.title }) else {
                                return false
                            }
                            
                            withAnimation(.spring()) {
                                let movedDrill = sessionModel.orderedSessionDrills.remove(at: sourceIndex)
                                sessionModel.orderedSessionDrills.insert(movedDrill, at: destinationIndex)
                            }
                            return true
                        }
                        .frame(height: layout.isPad ? 330 : 160)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .cornerRadius(15)
        // Sheet for searching and adding drills
        .sheet(isPresented: $appModel.viewState.showSearchDrills) {
            DrillSearchView(
                appModel: appModel,
                sessionModel: sessionModel,
                onDrillsSelected: { selectedDrills in
                    // Add the selected drills to the session
                    sessionModel.addDrillToSession(drills: selectedDrills)
                    
                    // Close the sheet
                    appModel.viewState.showSearchDrills = false
                },
                title: "Search Drills",
                actionButtonText: { count in
                    "Add \(count) \(count == 1 ? "Drill" : "Drills") to Session"
                },
                filterDrills: { drill in
                    sessionModel.orderedSessionDrills.contains(where: { $0.drill.id == drill.id })
                },
                isDrillSelected: { drill in
                    sessionModel.isDrillSelected(drill)
                }
            )
        }
    }
}
