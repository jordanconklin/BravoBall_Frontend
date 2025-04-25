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
        var remainingDrills = drills
        
        // Equipment filter - match any selected equipment
        if !filters.equipment.isEmpty {
            remainingDrills = remainingDrills.filter { drill in
                // Normalize equipment strings for comparison
                let normalizedDrillEquipment = drill.equipment.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
                let normalizedFilterEquipment = filters.equipment.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }

                
                // Check if drill has ANY of the required equipment
                let hasAnyRequiredEquipment = normalizedDrillEquipment.contains { equipment in
                    normalizedFilterEquipment.contains(equipment)
                }
                
                if !hasAnyRequiredEquipment {
                    print("❌ Drill '\(drill.title)' filtered out due to equipment mismatch")
                }
                return hasAnyRequiredEquipment
            }
            print("🔧 After equipment filter: \(remainingDrills.count) drills")
        } else {
            print("Skipped equipment since it is nil")
        }
        
        // Training Style filter
        if let styleFilter = filters.trainingStyle {
            remainingDrills = remainingDrills.filter { drill in
                let matches = drill.trainingStyle.lowercased() == styleFilter.lowercased()
                if !matches {
                    print("❌ Drill '\(drill.title)' filtered out due to style mismatch")
                }
                return matches
            }
            print("🎯 After training style filter: \(remainingDrills.count) drills")
        } else {
            print("Skipped training style since it is nil")
        }
        
        // Location filter
        if let locationFilter = filters.location {
            remainingDrills = remainingDrills.filter { drill in
                let matches = matchesLocationFilter(drill, locationFilter)
                if !matches {
                    print("❌ Drill '\(drill.title)' filtered out due to location mismatch")
                }
                return matches
            }
            print("📍 After location filter: \(remainingDrills.count) drills")
        } else {
            print("Skipped location since it is nil")
        }
        
        // Difficulty filter
        if let difficultyFilter = filters.difficulty {
            remainingDrills = remainingDrills.filter { drill in
                let matches = drill.difficulty.lowercased() == difficultyFilter.lowercased()
                if !matches {
                    print("❌ Drill '\(drill.title)' filtered out due to difficulty mismatch")
                }
                return matches
            }
            print("⭐ After difficulty filter: \(remainingDrills.count) drills")
        } else {
            print("Skipped difficulty since it is nil")
        }
        
        // Return remaining drills after filtering
        return remainingDrills
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
