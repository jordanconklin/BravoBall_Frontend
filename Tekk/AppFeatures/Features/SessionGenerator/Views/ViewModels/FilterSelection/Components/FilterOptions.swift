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
    
    // TODO: case enums for neatness and make this shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                
                clearFilterSelection()
                
                withAnimation {
                    appModel.viewState.showFilterOptions = false
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    Text("Clear Filters")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        .font(.custom("Poppins-Bold", size: 12))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            Divider()
            
            Button(action: {
                
                showFilterPrompt()
                
                withAnimation {
                    appModel.viewState.showFilterOptions = false
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    Text("Save Filters")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        .font(.custom("Poppins-Bold", size: 12))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            Divider()
            
            Button(action: {
                withAnimation(.spring(dampingFraction: 0.7)) {
                    appModel.viewState.showSavedFilters.toggle()
                    appModel.viewState.showFilterOptions = false
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    Text("Select Saved Filters")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        .font(.custom("Poppins-Bold", size: 12))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color.white)
        .frame(maxWidth: .infinity)

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
