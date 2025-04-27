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
    
    
    func updateSessionByFilters(change: FilterDataChange) {
        let availableDrills = getDrillsFromCache()
        print("📦 Retrieved \(availableDrills.count) drills from cache")
        
        // Apply filters based on what's active, will return filtered drills
        let filteredDrills = filterDrills(availableDrills, using: currentFilters)
        
    
        // Optimize for time if time filter is active
        if let timeFilter = selectedTime {
            let targetMinutes = convertTimeFilterToMinutes(timeFilter)
            let timeOptimizedDrills = optimizeDrillsForTime(drills: filteredDrills, targetMinutes: targetMinutes)
            print("⌛ After time optimization: \(timeOptimizedDrills.count) drills selected")
            updateOrderedSessionDrills(with: timeOptimizedDrills)
        } else {
            print("⏰ No time filter active, using all filtered drills")
            updateOrderedSessionDrills(with: filteredDrills)
        }
        
        filterChangeTracker.reset()
    }
    
    func filterDrills(_ drills: [DrillModel], using filters: DrillFilters) -> [DrillModel] {
        let maxDrills = 10
        var remainingDrills = drills
        
        // Equipment filter
        if !filters.equipment.isEmpty {
            remainingDrills = remainingDrills.filter { drill in
                let normalizedDrillEquipment = drill.equipment.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
                let normalizedFilterEquipment = filters.equipment.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
                return normalizedDrillEquipment.contains { equipment in
                    normalizedFilterEquipment.contains(equipment)
                }
            }
            
            // Early exit if no drill matches this filter
            if remainingDrills.isEmpty {
                return []
            }
        }

        // Training Style filter with randomization
        if let styleFilter = filters.trainingStyle {
            remainingDrills = remainingDrills.shuffled().prefix(maxDrills).filter { drill in
                drill.trainingStyle.lowercased() == styleFilter.lowercased()
            }
            
            if remainingDrills.isEmpty {
                return []
            }
        }

        // Location filter with randomization
        if let locationFilter = filters.location {
            remainingDrills = remainingDrills.shuffled().prefix(maxDrills).filter { drill in
                matchesLocationFilter(drill, locationFilter)
            }
            
            if remainingDrills.isEmpty {
                return []
            }
        }

        // Difficulty filter with final randomization
        if let difficultyFilter = filters.difficulty {
            remainingDrills = remainingDrills.shuffled().prefix(maxDrills).filter { drill in
                drill.difficulty.lowercased() == difficultyFilter.lowercased()
            }
        }
        
        if remainingDrills != drills {
            // Final randomization and limit
            return Array(remainingDrills.shuffled().prefix(maxDrills))
        } else {
            // Return empty array if no filter created
            return []
        }
    }
    
    func matchesLocationFilter(_ drill: DrillModel, _ locationFilter: String) -> Bool {
        switch locationFilter.lowercased() {
        case "full field":
            return drill.equipment.contains(where: { $0.lowercased().contains("full_field") })
        case "medium field":
            return !drill.equipment.contains(where: { $0.lowercased().contains("medium_field") })
        case "small space":
            return drill.equipment.contains(where: { $0.lowercased().contains("small_space") })
        case "location with goals":
            return drill.equipment.contains(where: { $0.lowercased().contains("location_with_goals") })
        case "location with wall":
            return drill.equipment.contains(where: { $0.lowercased().contains("location_with_wall") })
        default:
            return false
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
