//
//  testSesGenView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/22/25.
//

import SwiftUI
import RiveRuntime

// MARK: - Main Session Generator View
struct SessionGeneratorView: View {
    @ObservedObject var model: OnboardingModel
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

            HomePage(appModel: appModel, sessionModel: sessionModel)
                .frame(maxWidth: geometry.size.width)
                .frame(maxWidth: .infinity)

            // Golden button
            if sessionReady() {
                GoldenButton(appModel: appModel, viewGeometry: geometry)
                    .frame(maxWidth: min(geometry.size.width - 40, appModel.layout.buttonMaxWidth))
            }
            
            // Prompt to save filter
            if appModel.viewState.showSaveFiltersPrompt {
                SaveFiltersPrompt(appModel: appModel, sessionModel: sessionModel)
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
        // functions when UI of app changes
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
    }
    
    // MARK: Helper Functions
    private func sessionReady() -> Bool {
        !sessionModel.orderedSessionDrills.isEmpty && !appModel.viewState.showSkillSearch && appModel.viewState.showHomePage
    }
    
    private func BravoTextBubbleDelay() {
        // Initially hide the bubble
        appModel.viewState.showPreSessionTextBubble = false
        
        // Show it after a 1 second delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 0.3)) {
                appModel.viewState.showPreSessionTextBubble = true
            }
        }
    }
}

#Preview {
    // Create mock models with minimal initialization
    let mockOnboardingModel = OnboardingModel()
    let mockAppModel = MainAppModel()
    
    // Create a single test drill instead of mapping multiple
    let testDrill = DrillModel(
        title: "Test Passing Drill",
        skill: "Passing",
        sets: 3,
        reps: 10,
        duration: 15,
        description: "Basic passing drill",
        tips: ["Keep your eye on the ball"],
        equipment: ["Soccer ball"],
        trainingStyle: "Medium Intensity",
        difficulty: "Beginner"
    )
    
    let editableDrill = EditableDrillModel(
        drill: testDrill,
        setsDone: 0,
        totalSets: 3,
        totalReps: 10,
        totalDuration: 15,
        isCompleted: false
    )
    
    let mockSessionModel = SessionGeneratorModel(
        appModel: mockAppModel,
        onboardingData: OnboardingModel.OnboardingData()
    )
    
    // Set minimal test data
    mockSessionModel.selectedSkills = ["Passing"]
    mockSessionModel.orderedSessionDrills = [editableDrill]
    mockAppModel.viewState.showHomePage = true
    
    return SessionGeneratorView(
        model: mockOnboardingModel,
        appModel: mockAppModel,
        sessionModel: mockSessionModel
    )
}

