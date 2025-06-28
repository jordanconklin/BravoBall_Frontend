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
    
    let globalSettings = GlobalSettings()
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
    
    struct ViewState: Codable {
        var showingDrills = false
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
                print("❌ No latest session found in allCompletedSessions")
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
//    {
//        didSet {
//            if !isInitialLoad && !isLoggingOut && currentStreak != oldValue {
//                cacheCurrentStreak()
//                queueProgressSync()
//            }
//        }
//    }
    @Published var highestStreak: Int = 0
//    {
//        didSet {
//            if !isInitialLoad && !isLoggingOut && highestStreak != oldValue {
//                cacheHighestStreak()
//                queueProgressSync()
//            }
//        }
//    }
    @Published var countOfFullyCompletedSessions: Int = 0
//    {
//        didSet {
//            if !isInitialLoad && !isLoggingOut && countOfFullyCompletedSessions != oldValue {
//                cacheCompletedSessionsCount()
//                queueProgressSync()
//            }
//        }
//    }
    
    // TODO: better way to manage progress network calls?
    // madds debounce so all progress history isnt pushing individual network calls
    private func queueProgressSync() {
        let now = Date()
        if now.timeIntervalSince(lastProgressSyncTime) >= progressSyncDebounceInterval {
            lastProgressSyncTime = now
            syncProgressHistory()
        } else if !pendingProgressSync {
            pendingProgressSync = true
            // Schedule a sync after the debounce interval
            DispatchQueue.main.asyncAfter(deadline: .now() + progressSyncDebounceInterval) { [weak self] in
                guard let self = self else { return }
                self.pendingProgressSync = false
                self.lastProgressSyncTime = Date()
                self.syncProgressHistory()
            }
        }
    }
    
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
    
//    // MARK: - Cache Load Operations
//    func loadCachedData() {
//        // Cancel any existing loading task
//        loadingTask?.cancel()
//        
//        isInitialLoad = true
//        loadingError = nil
//        
//        print("\n📱 Loading cached data for current user...")
//        let userEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? "no user"
//        print("\n👤 USER SESSION INFO:")
//        print("----------------------------------------")
//        print("Current user email: \(userEmail)")
//        
//        // Load completed sessions
//        if let retrievedSessions: [CompletedSession] = cacheManager.retrieve(forKey: .allCompletedSessionsCase) {
//            allCompletedSessions = retrievedSessions
//            print("✅ Loaded \(allCompletedSessions.count) completed sessions")
//        }
//        
//        // Load progress history from cache first
//        let cachedCurrentStreak: Int = cacheManager.retrieve(forKey: .currentStreakCase) ?? 0
//        let cachedHighestStreak: Int = cacheManager.retrieve(forKey: .highestSreakCase) ?? 0
//        let cachedCompletedCount: Int = cacheManager.retrieve(forKey: .countOfCompletedSessionsCase) ?? 0
//        
//        // Set the values without triggering observers
//        self.currentStreak = cachedCurrentStreak
//        self.highestStreak = cachedHighestStreak
//        self.countOfFullyCompletedSessions = cachedCompletedCount
//        
//        print("✅ Loaded from cache - Current Streak: \(cachedCurrentStreak), Highest: \(cachedHighestStreak), Completed: \(cachedCompletedCount)")
//        print("----------------------------------------")
//        
//        // Create a new loading task
//        loadingTask = Task { [weak self] in
//            guard let self = self else { return }
//            
//            do {
//                let response = try await DataSyncService.shared.fetchProgressHistory()
//                
//                // Check if task was cancelled
//                if Task.isCancelled { return }
//                
//                // Only update if the backend values are different from cache
//                if response.currentStreak != cachedCurrentStreak ||
//                   response.highestStreak != cachedHighestStreak ||
//                   response.completedSessionsCount != cachedCompletedCount {
//                    
//                    await MainActor.run {
//                        guard !Task.isCancelled else { return }
//                        
//                        self.currentStreak = response.currentStreak
//                        self.highestStreak = response.highestStreak
//                        self.countOfFullyCompletedSessions = response.completedSessionsCount
//                        print("✅ Updated with backend data - Current: \(response.currentStreak), Highest: \(response.highestStreak), Completed: \(response.completedSessionsCount)")
//                    }
//                }
//            } catch {
//                if !Task.isCancelled {
//                    await MainActor.run {
//                        self.loadingError = error
//                        print("⚠️ Could not fetch from backend, using cached values: \(error)")
//                    }
//                }
//            }
//            
//            // Only set isInitialLoad to false if this task wasn't cancelled
//            if !Task.isCancelled {
//                await MainActor.run {
//                    self.isInitialLoad = false
//                }
//            }
//        }
//    }
//    
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
        
        // Debug: Print all available session dates
        print("🔍 Looking for session on date: \(date)")
        print("📅 Available session dates:")
        for (index, session) in allCompletedSessions.enumerated() {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let sessionDateString = formatter.string(from: session.date)
            print("   Session \(index): \(sessionDateString)")
            
            // Test the date comparison using year, month, day only
            let sessionComponents = calendar.dateComponents([.year, .month, .day], from: session.date)
            let targetComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let isSameDay = sessionComponents.year == targetComponents.year &&
                           sessionComponents.month == targetComponents.month &&
                           sessionComponents.day == targetComponents.day
            print("   Comparing with \(date): \(isSameDay)")
        }
        
        // Use a more robust date comparison that only looks at year, month, day
        let session = allCompletedSessions.first { session in
            let sessionComponents = calendar.dateComponents([.year, .month, .day], from: session.date)
            let targetComponents = calendar.dateComponents([.year, .month, .day], from: date)
            return sessionComponents.year == targetComponents.year &&
                   sessionComponents.month == targetComponents.month &&
                   sessionComponents.day == targetComponents.day
        }
        
        print("count in array: \(allCompletedSessions.count)")
        
        // Debug: Print when sessions are found for calendar dates
        if let foundSession = session {
            print("📅 Calendar found session for \(date): \(foundSession.totalCompletedDrills)/\(foundSession.totalDrills) completed")
        } else {
            print("❌ No session found for date \(date)")
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
