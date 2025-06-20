//
//  SavedFilterExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//
import Foundation

extension SessionGeneratorModel: SavedFiltersManagement {
    
    
    // Filter value that is selected, or if its empty
    func filterValue(for type: FilterType) -> String {
        let value = switch type {
        case .time:
            selectedTime ?? ""
        case .equipment:
            selectedEquipment.isEmpty ? "" : "Equipment (\(selectedEquipment.count))"
        case .trainingStyle:
            selectedTrainingStyle ?? ""
        case .location:
            selectedLocation ?? ""
        case .difficulty:
            selectedDifficulty ?? ""
        }
        
        return value
    }
    
    // Save filters into saved filters group
    func saveFiltersInGroup(name: String) {
        
        guard !name.isEmpty else { return }
        
        let savedFilters = SavedFiltersModel(
            name: name,
            savedTime: selectedTime,
            savedEquipment: selectedEquipment,
            savedTrainingStyle: selectedTrainingStyle,
            savedLocation: selectedLocation,
            savedDifficulty: selectedDifficulty
        )
        
        allSavedFilters.append(savedFilters)
        
        cacheFilterGroups(name: name)
    }
    
    // Load filter after clicking the name of saved filter
    func loadFilter(_ filter: SavedFiltersModel) {
        selectedTime = filter.savedTime
        selectedEquipment = filter.savedEquipment
        selectedTrainingStyle = filter.savedTrainingStyle
        selectedLocation = filter.savedLocation
        selectedDifficulty = filter.savedDifficulty
    }
    
}
