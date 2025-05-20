//
//  FilterSheet.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/24/25.
//

import SwiftUI

struct FilterSheet: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    
    let type: FilterType
    let dismiss: () -> Void
    
    var body: some View {
        // Filter dropdown
        VStack(alignment: .center, spacing: 12) {
            
            // Header
            HStack {
                Spacer()
                Text(type.rawValue)
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
            .padding(.horizontal)
            .padding(.top)
            
            // Options list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(optionsForType, id: \.self) { option in
                        Button(action: {
                            selectOption(option)
                        }) {
                            HStack {
                                Text(option)
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(appModel.globalSettings.primaryGrayColor)
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(isSelected(option) ? appModel.globalSettings.primaryYellowColor : Color.clear)
                                        .stroke(isSelected(option) ? appModel.globalSettings.primaryYellowColor : appModel.globalSettings.primaryGrayColor, lineWidth: 1)
                                        .frame(width: 20, height: 20)
                                    
                                    if isSelected(option) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 4)
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                }
            }
        }
        .onAppear {
            if type == .equipment {
                print("[FilterSheet] selectedEquipment: \(sessionModel.selectedEquipment)")
                print("[FilterSheet] Equipment options: \(FilterData.equipmentOptions)")
            }
        }
    }
    
    
    private var optionsForType: [String] {
        switch type {
        case .time: return FilterData.timeOptions
        case .equipment: return FilterData.equipmentOptions
        case .trainingStyle: return FilterData.trainingStyleOptions
        case .location: return FilterData.locationOptions
        case .difficulty: return FilterData.difficultyOptions
        }
    }
    
    private func isSelected(_ option: String) -> Bool {
        switch type {
        case .time: return sessionModel.selectedTime == option
        case .equipment: return sessionModel.selectedEquipment.contains(option)
        case .trainingStyle: return sessionModel.selectedTrainingStyle == option
        case .location: return sessionModel.selectedLocation == option
        case .difficulty: return sessionModel.selectedDifficulty == option
        }
    }

    private func selectOption(_ option: String) {
        switch type {
        case .time:
            if sessionModel.selectedTime == option {
                sessionModel.selectedTime = nil
                dismiss()
            } else {
                sessionModel.selectedTime = option
                dismiss()
            }
        case .equipment:
            if sessionModel.selectedEquipment.contains(option) {
                sessionModel.selectedEquipment.remove(option)
            } else {
                sessionModel.selectedEquipment.insert(option)
            }
        case .trainingStyle:
            if sessionModel.selectedTrainingStyle == option {
                sessionModel.selectedTrainingStyle = nil
                dismiss()
            } else {
                sessionModel.selectedTrainingStyle = option
                dismiss()
            }
        case .location:
            if sessionModel.selectedLocation == option {
                sessionModel.selectedLocation = nil
                dismiss()
            } else {
                sessionModel.selectedLocation = option
                dismiss()
            }
        case .difficulty:
            if sessionModel.selectedDifficulty == option {
                sessionModel.selectedDifficulty = nil
                dismiss()
            } else {
                sessionModel.selectedDifficulty = option
                dismiss()
            }
        }
    }
}
