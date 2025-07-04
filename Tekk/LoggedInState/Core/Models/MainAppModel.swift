///
//  MainAppModel.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/9/25.
//
// Contains other functions and variables within the main app

import Foundation
import UIKit
import RiveRuntime
import SwiftUI
import SwiftKeychainWrapper

class MainAppModel: ObservableObject {
    
    let layout = ResponsiveLayout()

    
    
    var isInitialLoad = true
    var isLoggingOut = false
    private let cacheManager = CacheManager.shared
    private var loadingTask: Task<Void, Never>?  // Track loading task
    
    // Add error state
    @Published private(set) var loadingError: Error?

    
    @Published var homeTab = RiveViewModel(fileName: "Tab_House")
    @Published var progressTab = RiveViewModel(fileName: "Tab_Calendar")
    @Published var savedTab = RiveViewModel(fileName: "Tab_Saved")
    @Published var profileTab = RiveViewModel(fileName: "Tab_Dude")
    
    @Published var mainTabSelected = 0
    @Published var inSimulationMode: Bool = false
    
    // View state
    @Published var viewState = ViewState()
    
    let currentDate: Date = Date()
    
    struct ViewState: Codable {
        var showStreakLostMessage: Bool = false
        var showingDrills: Bool = false
        var showDrillOptions: Bool = false
        var showHomePage: Bool = false
        var showPreSessionTextBubble: Bool = false
        var showPostSessionTextBubble: Bool = false
        var showFieldBehindHomePage: Bool = false
        var showFilterOptions: Bool = false
        var showGroupFilterOptions: Bool = false
        var showSavedFilters: Bool = false
        var showSaveFiltersPrompt: Bool = false
        var showSearchDrills: Bool = false
        var showSessionDeleteButtons: Bool = false
        var showDrillGroupDeleteButtons: Bool = false
        var showingDrillDetail: Bool = false
        var showSkillSearch: Bool = false
        var showSessionComplete: Bool = false
        var showBravo: Bool = true
        
        // Reset view states when user logs out / resets app
        mutating func reset() {
                showingDrills = false
                showHomePage = true
                showPreSessionTextBubble = false
                showPostSessionTextBubble = false
                showFieldBehindHomePage = false
                showFilterOptions = false
                showGroupFilterOptions = false
                showSavedFilters = false
                showSaveFiltersPrompt = false
                showSearchDrills = false
                showSessionDeleteButtons = false
                showingDrillDetail = false
                showSkillSearch = false
                showSessionComplete = false
                showBravo = true
            }
    }
    
    // Enus and types for filters
    
    @Published var selectedFilter: FilterType?
    
    // Function to map FilterType to FilterIcon
    func icon(for type: FilterType) -> FilterIcon {
        switch type {
        case .time:
            return .time
        case .equipment:
            return .equipment
        case .trainingStyle:
            return .trainingStyle
        case .location:
            return .location
        case .difficulty:
            return .difficulty
        }
    }
    
    
    // Types for search drills ByType section (automatically nil)
    @Published var selectedSkillButton: SkillType?
    @Published var selectedTrainingStyle: TrainingStyleType?
    @Published var selectedDifficulty: DifficultyType?
    

    
    
    
    // MARK: Calendar
    
    let calendar = Calendar.current
    
    @Published var allCompletedSessions: [CompletedSession] = [] {
        
        didSet {
            
            print("initial load state: \(isInitialLoad)")
            
            if !isInitialLoad && !isLoggingOut && allCompletedSessions.count > oldValue.count,
               let latestSession = allCompletedSessions.last {

                Task {
                    do {
                        // Sync the completed session
                        try await DataSyncService.shared.syncCompletedSession(
                            date: latestSession.date,
                            drills: latestSession.drills,
                            totalCompleted: latestSession.totalCompletedDrills,
                            total: latestSession.totalDrills
                        )
                        print("✅ Successfully synced latest completed session")
                        
                        // Then sync the progress history
                        try await DataSyncService.shared.syncProgressHistory(
                            currentStreak: currentStreak,
                            highestStreak: highestStreak,
                            completedSessionsCount: countOfFullyCompletedSessions
                        )
                        print("✅ Successfully synced progress history")
                    } catch {

                    }
                }
            } else {
                print("initial state, dont make changes to completed sessions")
            }
        }
    }
    @Published var selectedSession: CompletedSession? // For selecting into Drill Result View
    @Published var showCalendar = false
    @Published var showDrillResults = false
    
    // Add debounce properties
    private var lastProgressSyncTime: Date = Date()
    private let progressSyncDebounceInterval: TimeInterval = 1.0 // 1 second debounce
    private var pendingProgressSync = false
    
    @Published var currentStreak: Int = 0
    @Published var highestStreak: Int = 0
    @Published var countOfFullyCompletedSessions: Int = 0

    
    private func syncProgressHistory() {
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                // First verify the current values match what we expect
                let cachedCurrentStreak: Int = cacheManager.retrieve(forKey: .currentStreakCase) ?? 0
                let cachedHighestStreak: Int = cacheManager.retrieve(forKey: .highestSreakCase) ?? 0
                let cachedCompletedCount: Int = cacheManager.retrieve(forKey: .countOfCompletedSessionsCase) ?? 0
                
                // Only sync if our current values match the cache (ensures we're not working with stale data)
                guard currentStreak == cachedCurrentStreak &&
                      highestStreak == cachedHighestStreak &&
                      countOfFullyCompletedSessions == cachedCompletedCount else {
                    print("⚠️ Local values don't match cache, skipping sync")
                    return
                }
                
                try await DataSyncService.shared.syncProgressHistory(
                    currentStreak: currentStreak,
                    highestStreak: highestStreak,
                    completedSessionsCount: countOfFullyCompletedSessions
                )
                
                await MainActor.run {
                    self.loadingError = nil
                    print("✅ Successfully synced progress history with verified values")
                }
            } catch URLError.timedOut {
                print("⏱️ Progress history sync debounced - too soon since last request")
            } catch {
                await MainActor.run {
                    self.loadingError = error
                    print("❌ Error syncing progress history: \(error)")
                }
            }
        }
    }
    
    // MARK: - Cache Save Operations
    func cacheCompletedSessions() {
        cacheManager.cache(allCompletedSessions, forKey: .allCompletedSessionsCase)
        print("💾 Saved \(allCompletedSessions.count) completed sessions to cache")
    }
    
    func cacheCurrentStreak() {
        cacheManager.cache(currentStreak, forKey: .currentStreakCase)
        print("💾 Saved current streak: \(currentStreak)")
    }
    
    func cacheHighestStreak() {
        cacheManager.cache(highestStreak, forKey: .highestSreakCase)
        print("💾 Saved highest streak: \(highestStreak)")
    }
    
    func cacheCompletedSessionsCount() {
        cacheManager.cache(countOfFullyCompletedSessions, forKey: .countOfCompletedSessionsCase)
        print("💾 Saved completed sessions count: \(countOfFullyCompletedSessions)")
    }
 
    // Adding completed session into allCompletedSessions array
    func addCompletedSession(date: Date, drills: [EditableDrillModel], totalCompletedDrills: Int, totalDrills: Int) {
        let newSession = CompletedSession(
            date: date,
            drills: drills,
            totalCompletedDrills: totalCompletedDrills,
            totalDrills: totalDrills
        )
        allCompletedSessions.append(newSession)
        
        
        // Increase count of fully complete sessions if 100% done
        if totalCompletedDrills == totalDrills {
            countOfFullyCompletedSessions += 1
        }
        
        // Debugging
        print ("Session data received")
        print ("date: \(date)")
        print ("score: \(totalCompletedDrills) / \(totalDrills)")
        for drill in drills {
            print ("name: \(drill.drill.title)")
            print ("skill: \(drill.drill.skill)")
            print ("duration: \(drill.totalDuration)")
            print ("sets: \(drill.totalSets)")
            print ("reps: \(drill.totalReps)")
            print ("equipment: \(drill.drill.equipment)")
            print ("Session completed: \(drill.isCompleted)")
        }
    }
    
    // return the data in the drill results view in CompletedSession structure
    func getSessionForDate(_ date: Date) -> CompletedSession? {
        let calendar = Calendar.current
        
        // Use a more robust date comparison that only looks at year, month, day
        let session = allCompletedSessions.first { session in
            let sessionComponents = calendar.dateComponents([.year, .month, .day], from: session.date)
            let targetComponents = calendar.dateComponents([.year, .month, .day], from: date)
            return sessionComponents.year == targetComponents.year &&
                   sessionComponents.month == targetComponents.month &&
                   sessionComponents.day == targetComponents.day
        }
        

        
        return session
    }
    
    // MARK: App Settings
    
    // Alert types for ProfileVIew logout and delete buttons
    @Published var showAlert = false
    @Published var alertType: AlertType = .none
    
    
    // Case switches for ProfileVIew logout and delete buttons
    enum AlertType {
        case logout
        case delete
        case none
    }
    
        
    // Sets the highest streak
    func highestStreakSetter(streak: Int) {
        if streak > highestStreak {
            highestStreak = streak
        }
    }

    
    func alreadyCompletedToday() -> Bool {
        return allCompletedSessions.contains {
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .day)
        }
    }
    

    
    // When logging out
    
    func cleanupOnLogout() {
        print("🚨 cleanupOnLogout() called!")
        print("   - Stack trace: \(Thread.callStackSymbols.prefix(5).map { $0.components(separatedBy: " ").last ?? "unknown" })")
        print("   - Current allCompletedSessions count: \(allCompletedSessions.count)")
        
        // Set logout flag to prevent didSet observers from triggering
        isLoggingOut = true
        
        // Reset view state
        viewState = ViewState()
        
        // Reset tab selection
        mainTabSelected = 0
        
        // Reset selections
        selectedFilter = nil
        selectedSkillButton = nil
        selectedTrainingStyle = nil
        selectedDifficulty = nil
        selectedSession = nil
        showCalendar = false
        showDrillResults = false
        
        allCompletedSessions = []
        currentStreak = 0
        highestStreak = 0
        countOfFullyCompletedSessions = 0
        
        // Reset the logout flag
        isLoggingOut = false
        
        print("✅ cleanupOnLogout() completed - allCompletedSessions cleared")
    }
    
    deinit {
        loadingTask?.cancel()
    }
}

struct CompletedSession: Codable, Equatable {
    let date: Date
    let drills: [EditableDrillModel]
    let totalCompletedDrills: Int
    let totalDrills: Int
}
