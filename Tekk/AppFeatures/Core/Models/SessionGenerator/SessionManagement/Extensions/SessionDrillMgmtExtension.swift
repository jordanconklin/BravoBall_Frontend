//
//  SessionDrillMgmtExtension.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/6/25.
//

import Foundation

// MARK: - SessionDrillManagement Extension
extension SessionGeneratorModel: SessionDrillManagement {
    
    // MARK: - Session Management Methods
    func clearOrderedDrills() {
        orderedSessionDrills.removeAll()
    }
    
    func moveDrill(from source: IndexSet, to destination: Int) {
        orderedSessionDrills.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteDrillFromSession(drill: EditableDrillModel) {
        orderedSessionDrills.removeAll(where: { $0.drill.id == drill.drill.id })
    }
    
    func sessionNotComplete() -> Bool {
        orderedSessionDrills.contains(where: { $0.isCompleted == false })
    }
    
    func sessionsLeftToComplete() -> Int {
        orderedSessionDrills.count(where: {$0.isCompleted == false})
    }
    
    // Load drills from database and cache them
    func loadAndCacheDatabaseDrills() async {
        print("🔄 Loading drills from database...")
        
        // Clear existing cache first
        CacheManager.shared.clearCache(forKey: .databaseDrillsCase)
        print("🗑️ Cleared existing drill cache")
        
        do {
            let drillResponses = try await DrillSearchService.shared.searchDrills()
            let drills = DrillSearchService.shared.convertToLocalModels(drillResponses: drillResponses.items)
            
            // Print some debug info about the drills
            print("\n📊 DEBUG: Converting \(drillResponses.items?.count ?? 0) drills")
            if let firstFewDrills = drillResponses.items?.prefix(3) {
                print("\n🔍 Sample of first few drills:")
                for (index, drill) in firstFewDrills.enumerated() {
                    print("\nDrill \(index + 1):")
                    print("- Title:", drill.title)
                    print("- Primary Skill:", drill.primarySkill?.category ?? "None")
                    print("- Type:", drill.type)
                    print("- Secondary Skills:", drill.secondarySkills?.map { $0.category } ?? [])
                }
            }
            
            // Cache the drills
            CacheManager.shared.cache(drills, forKey: .databaseDrillsCase)
            print("✅ Cached \(drills.count) drills from database")
            
            // Print sample of cached drills
            print("\n📋 Sample of cached drills:")
            for (index, drill) in drills.prefix(3).enumerated() {
                print("\nCached Drill \(index + 1):")
                print("- Title:", drill.title)
                print("- Skill:", drill.skill)
                print("- SubSkills:", drill.subSkills)
            }
        } catch {
            print("❌ Error loading drills from database: \(error)")
        }
    }
    
    // Get drills from cache or fallback to test drills
    func getDrillsFromCache() -> [DrillModel] {
        if let cachedDrills: [DrillModel] = CacheManager.shared.retrieve(forKey: .databaseDrillsCase) {
            print("\n📋 Using \(cachedDrills.count) drills from cache")
            print("📋 Sample of cached drills:")
            for (index, drill) in cachedDrills.prefix(3).enumerated() {
                print("\nCached Drill \(index + 1):")
                print("- Title:", drill.title)
                print("- Skill:", drill.skill)
                print("- SubSkills:", drill.subSkills)
            }
            return cachedDrills
        }
        
        print("\n⚠️ No cached drills found, using test drills")
        let testDrills = Self.testDrills
        print("📋 Sample of test drills:")
        for (index, drill) in testDrills.prefix(3).enumerated() {
            print("\nTest Drill \(index + 1):")
            print("- Title:", drill.title)
            print("- Skill:", drill.skill)
            print("- SubSkills:", drill.subSkills)
        }
        return testDrills
    }
    
    
    
    
    // this will update the ordered drills based on the selected skills
    func updateSessionBySelectedSkills() {
        // Get drills from cache or fallback to test drills
        let availableDrills = getDrillsFromCache()
        
        print("\n🔍 DEBUG: Selected Skills:", selectedSkills)
        print("\n📊 DEBUG: Available Drills Count:", availableDrills.count)
        
        // Print first few drills to check their structure
        print("\n🔎 DEBUG: Sample of Available Drills:")
        for (index, drill) in availableDrills.prefix(5).enumerated() {
            print("\nDrill \(index + 1):")
            print("- Title:", drill.title)
            print("- Skill:", drill.skill)
            print("- SubSkills:", drill.subSkills)
        }
        
        
        // Filter drills based on selected skills
        let filteredDrills = availableDrills.filter { drill in
            // If no skills are selected, include no drills
            guard !selectedSkills.isEmpty else { return false }
            
            // Check if any of the selected skills match the drill's category
            return selectedSkills.contains { selectedSkill in
                
                // For specific cases where we need to check subSkills
                switch selectedSkill {
                
                //TODO: might be able to optimize this code for performance
                    
                case /* Dribbling cases */
                    "Close control", "Speed dribbling", "1v1 moves", "Change of direction", "Ball mastery",
                    /* First Touch cases */
                    "Ground control", "Aerial control", "Turn with ball", "Touch and move", "Juggling",
                    /* Passing cases */
                    "Short passing", "Long passing", "One touch passing", "Technique", "Passing with movement",
                    /* Shooting cases */
                    "Power shots", "Finesse shots", "First time shots", "1v1 to shoot", "Shooting on the run", "Volleying":
                    
                    let searchTerm = selectedSkill.lowercased().replacingOccurrences(of: " ", with: "_")
                    let hasMatch = drill.subSkills.contains(where: { $0.contains(searchTerm) })
                    
                    if hasMatch {
                        print("✅ MATCH FOUND: '\(drill.title)' matches control/dribbling category")
                        return true
                    }

                default:
                    return false
                }
                
                return false
            }
        }
        
        print("\n📝 DEBUG: Filtered Drills Count:", filteredDrills.count)
        if filteredDrills.isEmpty {
            print("⚠️ WARNING: No drills matched the selected skills!")
        } else {
            print("\n✅ Matched Drills:")
            filteredDrills.forEach { drill in
                print("- '\(drill.title)' (Skill: \(drill.skill), SubSkills: \(drill.subSkills))")
            }
        }
        
        // Convert filtered DrillModels to EditableDrillModels
        orderedSessionDrills = filteredDrills.map { drill in
            EditableDrillModel(
                drill: drill,
                setsDone: 0,
                totalSets: drill.sets,
                totalReps: drill.reps,
                totalDuration: drill.duration,
                isCompleted: false
            )
        }
        
        print("\n📱 Final Session Drills Count:", orderedSessionDrills.count)
    }
    
    
}
