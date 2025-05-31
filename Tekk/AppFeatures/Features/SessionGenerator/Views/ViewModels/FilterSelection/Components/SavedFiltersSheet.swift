//
//  SavedFiltersSheet.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI

struct SavedFiltersSheet: View {
    @ObservedObject var appModel: MainAppModel
    
    @EnvironmentObject var toastManager: ToastManager
    @ObservedObject var sessionModel: SessionGeneratorModel
    let dismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            
            HStack {
                
                Spacer()
                
                Text("Saved Filters")
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
                
                Spacer()
                Button(action: {
                    withAnimation(.spring(dampingFraction: 0.7)) {
                        dismiss()
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                }
            }
            
            
            if sessionModel.allSavedFilters.isEmpty {
                Text("No filters saved yet")
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(sessionModel.allSavedFilters) { filter in
                            Button(action: {
                                dismiss()
                                sessionModel.loadFilter(filter)
                                toastManager.showToast(.success("Filters updated"))
                            }) {
                                HStack {
                                    Text(filter.name)
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                                    Spacer()
                                    
                                    Checkbox(appModel: appModel, isSelected: savedFiltersAlreadySelected(filter))
                                }
                                .padding(.vertical, 8)
                            }
                            .disabled(savedFiltersAlreadySelected(filter))
                            Divider()
                            
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func savedFiltersAlreadySelected(_ filters: SavedFiltersModel) -> Bool {
        return filters.savedTime == sessionModel.selectedTime &&
        filters.savedEquipment == sessionModel.selectedEquipment &&
        filters.savedTrainingStyle == sessionModel.selectedTrainingStyle &&
        filters.savedLocation == sessionModel.selectedLocation &&
        filters.savedDifficulty == sessionModel.selectedDifficulty
    }

}
