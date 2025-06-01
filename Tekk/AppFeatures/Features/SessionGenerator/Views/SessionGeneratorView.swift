//
//  testSesGenView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/22/25.
//

import SwiftUI
import RiveRuntime

// Main session page view
struct SessionGeneratorView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Environment(\.viewGeometry) var geometry
    
    @State private var savedFiltersName: String  = ""
    @State private var searchSkillsText: String = ""
    

        
    
    // MARK: Main view
    var body: some View {
        ZStack(alignment: .bottom) {
            // Sky background color
            Color(hex:"bef1fa")
                .ignoresSafeArea()

            SessionGeneratorHomePage(appModel: appModel, sessionModel: sessionModel, searchSkillsText: $searchSkillsText, geometry: geometry)
                .frame(maxWidth: geometry.size.width)
                .frame(maxWidth: .infinity)


            // Golden button
            if sessionReady() {
                StartButton(appModel: appModel, sessionModel: sessionModel) {
                    withAnimation(.spring(dampingFraction: 0.7)) {
                        appModel.viewState.showHomePage = false
                        appModel.viewState.showPreSessionTextBubble = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation(.spring(dampingFraction: 0.7)) {
                            appModel.viewState.showFieldBehindHomePage = true
                        }
                    }
                }
                .frame(maxWidth: min(geometry.size.width - 40, appModel.layout.buttonMaxWidth))
                .offset(y: -10)
            }
            
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
        // Sheet pop-up for each filter
        .sheet(item: $appModel.selectedFilter) { type in
            FilterSheet(
                appModel: appModel,
                sessionModel: sessionModel,
                type: type
            ) {
                appModel.selectedFilter = nil
            }
            .presentationDragIndicator(.hidden)
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
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(appModel.layout.sheetHeight)])
            .frame(width: geometry.size.width)
        }
        // Sheet pop-up for filter option button
        .sheet(isPresented: $appModel.viewState.showFilterOptions) {
            FilterOptions(
                appModel: appModel,
                sessionModel: sessionModel
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(appModel.layout.sheetHeight)])
            .frame(width: geometry.size.width)
        }
    }
    
    private func sessionReady() -> Bool {
        !sessionModel.orderedSessionDrills.isEmpty && !appModel.viewState.showSkillSearch && appModel.viewState.showHomePage
    }
}

#if DEBUG
struct SessionGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        let onboardingModel = OnboardingModel()
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
        SessionGeneratorView(onboardingModel: onboardingModel, appModel: appModel, sessionModel: sessionModel)
    }
}
#endif

