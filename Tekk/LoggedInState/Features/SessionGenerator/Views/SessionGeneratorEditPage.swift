//
//  SessionGeneratorEditPage.swift
//  BravoBall
//
//  Created by Jordan on 5/15/25.
//

import SwiftUI

struct SessionGeneratorEditPage: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let globalSettings = GlobalSettings.shared
    
    var geometry: ViewGeometry
    
    @Environment(\.dismiss) private var dismiss
    @State private var savedFiltersName: String  = ""
    @State private var searchSkillsText: String = ""
    @State private var showInfoSheet = false
    
    @StateObject private var localToastManager = ToastManager()
    

    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .bottom) {
                
                VStack(alignment: .center, spacing: 0) {
                    
                    HStack {
                        // Info button to show explanation popup
                        Button(action: {
                            Haptic.light()
                            showInfoSheet = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 28, weight: .regular))
                                .foregroundColor(globalSettings.primaryGrayColor)
                        }
                        .accessibilityLabel("About Session Generator")
                        
                        Spacer()
                        
                        // Section title
                        Text("Edit Session")
                            .font(.custom("Poppins-Bold", size: 20))
                            .foregroundColor(globalSettings.primaryDarkColor)
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        Button("Done") {
                            Haptic.light()
                            appModel.viewState.showSessionDeleteButtons = false
                            dismiss()
                        }
                        .foregroundColor(Color.blue)
                        .font(.custom("Poppins-Bold", size: 16))
                    }
                    .padding()
                    
                    
                    SkillSearchBar(appModel: appModel, sessionModel: sessionModel, searchText: $searchSkillsText)
                        .padding(.horizontal)
                    
                    // If skills search bar is selected
                    if appModel.viewState.showSkillSearch {
                        // New view for searching skills
                        SearchSkillsView(
                            appModel: appModel,
                            sessionModel: sessionModel,
                            searchText: $searchSkillsText
                        )
                        // If skills search bar is not selected
                    } else {
                        FilterScrollView(appModel: appModel, sessionModel: sessionModel, geometry: geometry)
                            .frame(width: geometry.size.width)
                        // Main content
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: appModel.layout.standardSpacing) {
                                GeneratedDrillsSection(appModel: appModel, sessionModel: sessionModel, toastManager: localToastManager)
                            }
                        }
                        
                    }
                }
                .background(Color.white)
                
                // Prompt to save filter
                if appModel.viewState.showSaveFiltersPrompt {
                    SaveFiltersPromptView(
                        sessionModel: sessionModel,
                        savedFiltersName: $savedFiltersName
                    ) {
                        // Close the view when the user is done saving filters
                        appModel.viewState.showSaveFiltersPrompt = false
                    }
                }
                
                FloatingAddButton(
                    appModel: appModel
                ){
                    Haptic.light()
                    appModel.viewState.showSearchDrills = true
                }
            }
            .navigationDestination(item: $sessionModel.selectedDrill) { drill in

                DrillDetailView(appModel: appModel, sessionModel: sessionModel, drill: drill)
            }
            
        }
        .toastOverlay()
        .environmentObject(localToastManager)
        
        
        .animation(.easeInOut(duration: 0.4), value: appModel.viewState.showFieldBehindHomePage)
        .animation(.easeInOut(duration: 0.4), value: appModel.viewState.showHomePage)
        .onAppear {
            BravoTextBubbleDelay()
        }

        // Sheet pop-up for each filter
        .sheet(item: $appModel.selectedFilter) { type in
            FilterSheet(
                appModel: appModel,
                sessionModel: sessionModel,
                type: type
            ) {
                appModel.selectedFilter = nil
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.height(appModel.layout.sheetHeight)])
            .frame(width: geometry.size.width)
        }
        // Sheet pop-up for saved filters
        .sheet(isPresented: $appModel.viewState.showSavedFilters) {
            SavedFiltersSheet(
                appModel: appModel,
                sessionModel: sessionModel,
                dismiss: { appModel.viewState.showSavedFilters = false }
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium, .large])
            .frame(width: geometry.size.width)
        }
        // Sheet pop-up for filter option button
        .sheet(isPresented: $appModel.viewState.showFilterOptions) {
            FilterOptions(
                appModel: appModel,
                sessionModel: sessionModel
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.height(appModel.layout.sheetHeight)])
            .frame(width: geometry.size.width)
        }
        // Info popup sheet
        .sheet(isPresented: $showInfoSheet) {
            InfoPopupView(
                title: "What is the Session Generator?",
                description: "The Session Generator lets you build a custom soccer training session.\n\nUse the filters above to set your available time, equipment, and focus areas. Search for specific skills or browse recommended drills.\n\nAdd drills with the plus button, and remove them with the trash icon. Your selected drills will appear in the session list below.\n\nWhen you're ready, start your session to track your progress and complete your personalized training!",
                onClose: { showInfoSheet = false }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
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
    

    func BravoTextBubbleDelay() {
        // Initially hide the bubble
        appModel.viewState.showPreSessionTextBubble = false
        // Show it after a 1 second delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 0.3)) {
                appModel.viewState.showPreSessionTextBubble = true
            }
        }
    }
    
    private func sessionReady() -> Bool {
        !sessionModel.orderedSessionDrills.isEmpty && !appModel.viewState.showSkillSearch && appModel.viewState.showHomePage
    }
    
    
}

#if DEBUG
struct SessionGeneratorEditPage_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel()
        @State var searchSkillsText = ""
        let geometry = ViewGeometry(size: CGSize(width: 390, height: 844), safeAreaInsets: EdgeInsets())
        return SessionGeneratorEditPage(appModel: appModel, sessionModel: sessionModel, geometry: geometry)
    }
}
#endif 
