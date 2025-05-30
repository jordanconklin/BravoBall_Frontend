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
    
    var body: some View {
        LazyVStack(alignment: .center, spacing: layout.standardSpacing) {
                HStack {
                    
                    Spacer()
                    
                    Text("Session")
                        .font(.custom("Poppins-Bold", size: 20))
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        .padding(.leading, 70)
                    
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
                        Text("Choose a skill or drill to create your session")
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
                SearchDrillsSheetView(appModel: appModel, sessionModel: sessionModel, dismiss: { appModel.viewState.showSearchDrills = false })
            }
    }
    
//    private func keepDeleteButtonsShowing() -> Bool {
//        // First check if we have drills to delete
//        guard !sessionModel.orderedSessionDrills.isEmpty else { return false }
//        
//        // Then check if we're in a state where we should hide delete buttons
//        let shouldHideDeleteButtons = appModel.viewState.showSkillSearch ||
//                                    !appModel.viewState.showHomePage ||
//                                    appModel.viewState.showFieldBehindHomePage
//        
//        return !shouldHideDeleteButtons
//    }
}
