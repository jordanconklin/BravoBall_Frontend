//
//  FilterMgmtExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/24/25.
//

import Foundation

enum FilterDataChange {
    case selectedTimeChanged
    case selectedEquipmentChanged
    case selectedTrainingStyleChanged
    case selectedLocationChanged
    case selectedDifficulty
}


struct DrillFilters {
    let time: String?
    let equipment: Set<String>
    let trainingStyle: String?
    let location: String?
    let difficulty: String?
}

// First, make sure your FilterChangeTracker struct is defined
struct FilterChangeTracker {
    var selectedTimeChanged: Bool = false
    var selectedEquipmentChanged: Bool = false
    var selectedTrainingStyleChanged: Bool = false
    var selectedLocationChanged: Bool = false
    var selectedDifficulty: Bool = false
    
    mutating func reset() {
        selectedTimeChanged = false
        selectedEquipmentChanged = false
        selectedTrainingStyleChanged = false
        selectedLocationChanged = false
        selectedDifficulty = false
    }
}


// Add these functions to your SessionGeneratorModel class
extension SessionGeneratorModel {
    
    var currentFilters: DrillFilters {
        DrillFilters(
            time: selectedTime,
            equipment: selectedEquipment,
            trainingStyle: selectedTrainingStyle,
            location: selectedLocation,
            difficulty: selectedDifficulty
        )
    }
    
    func updateSessionByFilters(change: FilterDataChange) {
        let availableDrills = getDrillsFromCache()
        
        // Apply filters based on what's active, will return filtered drills
        let filteredDrills = filterDrills(availableDrills, using: currentFilters)
        
        // Optimize for time if time filter is active
        if let timeFilter = selectedTime {
            let targetMinutes = convertTimeFilterToMinutes(timeFilter)
            let timeOptimizedDrills = optimizeDrillsForTime(drills: filteredDrills, targetMinutes: targetMinutes)
            updateOrderedSessionDrills(with: timeOptimizedDrills)
        } else {
            updateOrderedSessionDrills(with: filteredDrills)
        }
        
        filterChangeTracker.reset()
    }
    
    func convertTimeFilterToMinutes(_ timeFilter: String) -> Int {
        switch timeFilter {
        case "15min": return 15
        case "30min": return 30
        case "45min": return 45
        case "1h": return 60
        case "1h30": return 90
        case "2h+": return 120
        default: return 60
        }
    }
    
    func optimizeDrillsForTime(drills: [DrillModel], targetMinutes: Int) -> [DrillModel] {
        print("🎯 Optimizing drills for target time: \(targetMinutes) minutes")
        
        let sortedDrills = drills.sorted { $0.duration < $1.duration }
        var selectedDrills: [DrillModel] = []
        var currentTotalTime = 0
        
        // First pass: Add drills while staying under target time
        for drill in sortedDrills {
            if currentTotalTime + drill.duration <= targetMinutes {
                selectedDrills.append(drill)
                currentTotalTime += drill.duration
                print("✅ Added drill '\(drill.title)' (\(drill.duration)min), total time now: \(currentTotalTime)min")
            }
        }
        
        // Optimization pass if we're under target
        if targetMinutes - currentTotalTime > 5 {
            for drill in sortedDrills.reversed() {
                if !selectedDrills.contains(where: { $0.id == drill.id }) {
                    let timeAfterAdding = currentTotalTime + drill.duration
                    if timeAfterAdding <= targetMinutes {
                        selectedDrills.append(drill)
                        currentTotalTime = timeAfterAdding
                    }
                }
            }
        }
        
        return selectedDrills
    }
    
    func filterDrills(_ drills: [DrillModel], using filters: DrillFilters) -> [DrillModel] {
        return drills.filter { drill in
            // Equipment filter - match any selected equipment
            if !filters.equipment.isEmpty {
                let hasAnyRequiredEquipment = drill.equipment.contains(where: { equipment in
                    filters.equipment.contains(equipment.lowercased())
                })
                if !hasAnyRequiredEquipment { return false }
            }
            
            // Training Style filter
            if let styleFilter = filters.trainingStyle {
                if drill.trainingStyle.lowercased() != styleFilter.lowercased() {
                    return false
                }
            }
            
            // Location filter
            if let locationFilter = filters.location {
                if !matchesLocationFilter(drill, locationFilter) {
                    return false
                }
            }
            
            // Difficulty filter
            if let difficultyFilter = filters.difficulty {
                if drill.difficulty.lowercased() != difficultyFilter.lowercased() {
                    return false
                }
            }
            
            return true
        }
    }
    
    func matchesLocationFilter(_ drill: DrillModel, _ locationFilter: String) -> Bool {
        switch locationFilter.lowercased() {
        case "field with goals":
            return drill.equipment.contains(where: { $0.lowercased().contains("goal") })
        case "small field":
            return !drill.equipment.contains(where: { $0.lowercased().contains("goal") })
        case "indoor court":
            return drill.equipment.contains(where: { $0.lowercased().contains("indoor") }) ||
                   !drill.equipment.contains(where: { $0.lowercased().contains("field") })
        default:
            return true
        }
    }
    
    func updateOrderedSessionDrills(with drills: [DrillModel]) {
        orderedSessionDrills = drills.map { drill in
            EditableDrillModel(
                drill: drill,
                setsDone: 0,
                totalSets: drill.sets,
                totalReps: drill.reps,
                totalDuration: drill.duration,
                isCompleted: false
            )
        }
        
        // debugging
        let totalSessionDuration = orderedSessionDrills.reduce(0) { $0 + $1.totalDuration }
        print("\n📱 Updated session with \(orderedSessionDrills.count) drills")
        print("⏱️ Total session duration: \(totalSessionDuration) minutes")
        
        if !isInitialLoad {
            markAsNeedingSave(change: .orderedDrills)
        }
    }
}
