//
//  FilterTypes.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/24/25.
//

import SwiftUI
import RiveRuntime


enum FilterType: String, CaseIterable, Identifiable {
    case time = "Time"
    case equipment = "Equipment"
    case trainingStyle = "Training Style"
    case location = "Location"
    case difficulty = "Difficulty"
    
    var id: String { rawValue }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .time:
            RiveViewModel(fileName: "Prereq_Time").view()
                .frame(width: 30, height: 30)
        case .equipment:
            RiveViewModel(fileName: "Prereq_Equipment").view()
                .frame(width: 30, height: 30)
        case .trainingStyle:
            RiveViewModel(fileName: "Prereq_Training_Style").view()
                .frame(width: 30, height: 30)
        case .location:
            RiveViewModel(fileName: "Prereq_Location").view()
                .frame(width: 30, height: 30)
        case .difficulty:
            RiveViewModel(fileName: "Prereq_Difficulty").view()
                .frame(width: 30, height: 30)
        }
    }
}

enum FilterIcon {
    case time
    case equipment
    case trainingStyle
    case location
    case difficulty
    
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .time:
            RiveViewModel(fileName: "Prereq_Time").view()
                .frame(width: 30, height: 30)
        case .equipment:
            RiveViewModel(fileName: "Prereq_Equipment").view()
                .frame(width: 30, height: 30)
        case .trainingStyle:
            RiveViewModel(fileName: "Prereq_Training_Style").view()
                .frame(width: 30, height: 30)
        case .location:
            RiveViewModel(fileName: "Prereq_Location").view()
                .frame(width: 30, height: 30)
        case .difficulty:
            RiveViewModel(fileName: "Prereq_Difficulty").view()
                .frame(width: 30, height: 30)
        }
    }
}


// TODO: will need more for recovery, etc
enum TrainingStyleType: String, CaseIterable {
    case medium = "Medium"
    case high = "High"
}

enum DifficultyType: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}


enum FilterData {
    // Filter options
    static let timeOptions = ["15min", "30min", "45min", "1h", "1h30", "2h+"]
    static let equipmentOptions = ["balls", "cones", "goals"]
    static let trainingStyleOptions = ["medium intensity", "high intensity", "game prep", "game recovery", "rest day"]
    static let locationOptions = ["field with goals", "small field", "indoor court"]
    static let difficultyOptions = ["beginner", "intermediate", "advanced"]
}

struct SavedFiltersModel: Codable, Identifiable, Equatable {
    let id: UUID
    let backendId: Int?  // Add this to store the server's ID
    let name: String
    let savedTime: String?
    let savedEquipment: Set<String>
    let savedTrainingStyle: String?
    let savedLocation: String?
    let savedDifficulty: String?
    
    init(id: UUID? = nil, backendId: Int? = nil, name: String, savedTime: String?, savedEquipment: Set<String>, savedTrainingStyle: String?, savedLocation: String?, savedDifficulty: String?) {
        self.id = id ?? UUID()  // Use provided ID or generate new one
        self.backendId = backendId
        self.name = name
        self.savedTime = savedTime
        self.savedEquipment = savedEquipment
        self.savedTrainingStyle = savedTrainingStyle
        self.savedLocation = savedLocation
        self.savedDifficulty = savedDifficulty
    }
    
    // for snake_case and camelCase conversion
    enum CodingKeys: String, CodingKey {
        case id
        case backendId = "backend_id"
        case name
        case savedTime = "saved_time"
        case savedEquipment = "saved_equipment"
        case savedTrainingStyle = "saved_training_style"
        case savedLocation = "saved_location"
        case savedDifficulty = "saved_difficulty"
    }
    
    // Implement Equatable
    static func == (lhs: SavedFiltersModel, rhs: SavedFiltersModel) -> Bool {
        // Compare all relevant fields
        return lhs.id == rhs.id &&
               lhs.backendId == rhs.backendId &&
               lhs.name == rhs.name &&
               lhs.savedTime == rhs.savedTime &&
               lhs.savedEquipment == rhs.savedEquipment &&
               lhs.savedTrainingStyle == rhs.savedTrainingStyle &&
               lhs.savedLocation == rhs.savedLocation &&
               lhs.savedDifficulty == rhs.savedDifficulty
    }
}
