//
//  FilterOptions.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/24/25.
//

import SwiftUI

// TODO: enum this


struct FilterOptions: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let globalSettings = GlobalSettings.shared
    
    // TODO: case enums for neatness and make this shared
    
    var body: some View {
        OptionsSheet(
            title: "Filter Options",
            onDismiss: {
                appModel.viewState.showFilterOptions = false
            }
        ) {
            VStack(alignment: .leading, spacing: 5) {
                OptionButton(
                    icon: "xmark.circle",
                    title: "Clear Filters"
                ) {
                    Haptic.light()
                    clearFilterSelection()
                    
                    withAnimation {
                        appModel.viewState.showFilterOptions = false
                    }
                }
                
                Divider()
                
                OptionButton(
                    icon: "square.and.arrow.down",
                    title: "Save Filters"
                ) {
                    Haptic.light()
                    showFilterPrompt()
                    
                    withAnimation {
                        appModel.viewState.showFilterOptions = false
                    }
                }
                
                Divider()
                
                OptionButton(
                    icon: "list.bullet",
                    title: "Select Saved Filters"
                ) {
                    Haptic.light()
                    withAnimation(.spring(dampingFraction: 0.7)) {
                        appModel.viewState.showSavedFilters.toggle()
                        appModel.viewState.showFilterOptions = false
                    }
                }
            }
        }
    }
    
    // Show Save Filter prompt
    private func showFilterPrompt() {
        if appModel.viewState.showSaveFiltersPrompt == true {
            appModel.viewState.showSaveFiltersPrompt = false
        } else {
            appModel.viewState.showSaveFiltersPrompt = true
        }
    }
    
    // Clears filter selected options
    private func clearFilterSelection() {
        sessionModel.selectedTime = nil
        sessionModel.selectedEquipment.removeAll()
        sessionModel.selectedTrainingStyle = nil
        sessionModel.selectedLocation = nil
        sessionModel.selectedDifficulty = nil
    }


    
    private func showSavedFilters() {
        if appModel.viewState.showSavedFilters == true {
            appModel.viewState.showSavedFilters = false
        } else {
            appModel.viewState.showSavedFilters = true
        }
    }
}
