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
    var geometry: ViewGeometry
    
    @Environment(\.dismiss) private var dismiss
    @State private var savedFiltersName: String  = ""
    @State private var searchSkillsText: String = ""
    @State private var showInfoSheet = false
    

    var body: some View {
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
                                .foregroundColor(appModel.globalSettings.primaryGrayColor)
                        }
                        .accessibilityLabel("About Session Generator")
                        
                        Spacer()
                        
                        // Section title
                        Text("Edit Session")
                            .font(.custom("Poppins-Bold", size: 20))
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        Button("Done") {
                            Haptic.light()
                            appModel.viewState.showSessionDeleteButtons = false
                            dismiss()
                        }
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
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
                                GeneratedDrillsSection(appModel: appModel, sessionModel: sessionModel)
                            }
                        }
                        
                    }
                }
                .background(Color.white)
//            
//            // Golden button
//            if sessionReady() {
//                StartButton(appModel: appModel, sessionModel: sessionModel) {
//                    withAnimation(.easeInOut(duration: 0.4)) {
//                        appModel.viewState.showHomePage = false
//                        appModel.viewState.showPreSessionTextBubble = false
//                        appModel.viewState.showFieldBehindHomePage = true
//                    }
//                }
//                .frame(maxWidth: min(geometry.size.width - 40, appModel.layout.buttonMaxWidth))
//                .offset(y: -10)
//            }
            
            // Prompt to save filter
            if appModel.viewState.showSaveFiltersPrompt {
                SaveFiltersPromptView(
                    appModel: appModel,
                    sessionModel: sessionModel,
                    savedFiltersName: $savedFiltersName
                ) {
                    // Close the view when the user is done saving filters
                    appModel.viewState.showSaveFiltersPrompt = false
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appModel.viewState.showFieldBehindHomePage)
        .animation(.easeInOut(duration: 0.4), value: appModel.viewState.showHomePage)
        .onAppear {
            BravoTextBubbleDelay()
        }
        .onDisappear {
            sessionModel.saveChanges()
        }
        .onChange(of: UIApplication.shared.applicationState) {
            if UIApplication.shared.applicationState == .background {
                sessionModel.saveChanges()
            }
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
            .presentationDetents([.height(appModel.layout.sheetHeight)])
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
        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
        @State var searchSkillsText = ""
        let geometry = ViewGeometry(size: CGSize(width: 390, height: 844), safeAreaInsets: EdgeInsets())
        return SessionGeneratorEditPage(appModel: appModel, sessionModel: sessionModel, geometry: geometry)
    }
}
#endif 
