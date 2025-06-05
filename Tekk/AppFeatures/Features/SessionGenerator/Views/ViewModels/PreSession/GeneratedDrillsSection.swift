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
    @State private var showInfoSheet = false
    
    var body: some View {
        LazyVStack(alignment: .center, spacing: layout.standardSpacing) {
            HStack {
                // Info button
                Button(action: { showInfoSheet = true }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                        .padding(.trailing, 8)
                }
                .accessibilityLabel("About Session Generator")
                
                Spacer()
                
                Text("Session")
                    .font(.custom("Poppins-Bold", size: 20))
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    .padding(.leading, 30)
                
                Spacer()
                
                Button(action: {
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
                
                Button(action: {
                    appModel.viewState.showSearchDrills = true
                }) {
                    RiveViewModel(fileName: "Plus_Button").view()
                        .frame(width: 30, height: 30)
                }
            }
 
            
            if sessionModel.orderedSessionDrills.isEmpty {
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
                ForEach($sessionModel.orderedSessionDrills, id: \.drill.id) { $editableDrill in
                    HStack {
                        if appModel.viewState.showSessionDeleteButtons {
                            Button(action: {
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
                        .frame(height: layout.isPad ? 340 : 170)
                    }
                }
            }

        }
        .padding(.horizontal)
        .padding(.top, 10)
        .cornerRadius(15)
        .sheet(isPresented: $appModel.viewState.showSearchDrills) {
            DrillSearchView(
                appModel: appModel,
                sessionModel: sessionModel,
                onDrillsSelected: { selectedDrills in
                    // Add the selected drills to the session
                    sessionModel.addDrillToSession(drills: selectedDrills)
                    
                    // Close the sheet
                    appModel.viewState.showSearchDrills = false
                    
                    // Call the dismiss callback
                    dismiss()
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
        .sheet(isPresented: $showInfoSheet) {
            InfoPopupView(
                title: "What is the Session Generator?",
                description: "The Session Generator lets you build a custom soccer training session.\n\nUse the filters above to set your available time, equipment, and focus areas. Search for specific skills or browse recommended drills.\n\nAdd drills with the plus button, and remove them with the trash icon. Your selected drills will appear in the session list below.\n\nWhen you're ready, start your session to track your progress and complete your personalized training!",
                onClose: { showInfoSheet = false }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}
