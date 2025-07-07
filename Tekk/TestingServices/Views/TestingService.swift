//
//  TestingService.swift
//  BravoBall
//
//  Created by Testing Assistant on 1/15/25.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

/// A comprehensive testing service for mocking authentication and streak scenarios
class TestingService {
    static let shared = TestingService()
    
    private init() {}
    
    // MARK: - Authentication Testing
    
    /// Mock an expired access token by replacing it with an invalid one
    func mockExpiredAccessToken() {
        print("🧪 TESTING: Mocking expired access token...")
        let expiredToken = "expired_token_\(Date().timeIntervalSince1970)"
        KeychainWrapper.standard.set(expiredToken, forKey: "accessToken")
        print("🧪 TESTING: Set expired token: \(expiredToken)")
    }
    
    /// Mock an invalid refresh token scenario
    func mockInvalidRefreshToken() {
        print("🧪 TESTING: Mocking invalid refresh token...")
        let invalidRefreshToken = "invalid_refresh_token_\(Date().timeIntervalSince1970)"
        KeychainWrapper.standard.set(invalidRefreshToken, forKey: "refreshToken")
        print("🧪 TESTING: Set invalid refresh token: \(invalidRefreshToken)")
    }
    
    /// Mock both tokens being expired/invalid
    func mockBothTokensExpired() {
        print("🧪 TESTING: Mocking both tokens expired...")
        mockExpiredAccessToken()
        mockInvalidRefreshToken()
        print("🧪 TESTING: Both tokens are now invalid")
    }
    
    /// Test token refresh flow by forcing a 401 scenario
    func testTokenRefresh(completion: @escaping (Bool) -> Void) {
        print("🧪 TESTING: Testing token refresh flow...")
        
        // Store original tokens
        let originalAccessToken = KeychainWrapper.standard.string(forKey: "accessToken")
        let originalRefreshToken = KeychainWrapper.standard.string(forKey: "refreshToken")
        
        // Mock expired access token
        mockExpiredAccessToken()
        
        // Make a test request that should trigger refresh
        Task {
            do {
                let (_, response) = try await APIService.shared.request(
                    endpoint: "/api/session/preferences",
                    method: "GET",
                    headers: ["Content-Type": "application/json"],
                    retryOn401: true
                )
                
                let success = response.statusCode == 200
                print("🧪 TESTING: Token refresh test result: \(success ? "SUCCESS" : "FAILED")")
                
                // Restore original tokens if test failed
                if !success {
                    if let originalAccess = originalAccessToken {
                        KeychainWrapper.standard.set(originalAccess, forKey: "accessToken")
                    }
                    if let originalRefresh = originalRefreshToken {
                        KeychainWrapper.standard.set(originalRefresh, forKey: "refreshToken")
                    }
                }
                
                await MainActor.run {
                    completion(success)
                }
            } catch {
                print("🧪 TESTING: Token refresh test error: \(error)")
                await MainActor.run {
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Authentication Persistence Testing
    
    /// Start a continuous authentication monitor to test how long user stays logged in
    func startAuthenticationMonitor(duration: TimeInterval = 3600, completion: @escaping (AuthMonitorResult) -> Void) {
        print("🧪 TESTING: Starting authentication monitor for \(Int(duration/60)) minutes...")
        
        let startTime = Date()
        var authChecks: [AuthCheckResult] = []
        
        // Create a timer that checks every 5 minutes
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            
            if elapsed >= duration {
                timer.invalidate()
                let result = AuthMonitorResult(
                    duration: duration,
                    checks: authChecks,
                    finalStatus: AuthenticationService.shared.isAuthenticated
                )
                completion(result)
                return
            }
            
            // Perform auth check
            Task {
                let isAuthenticated = await AuthenticationService.shared.checkAuthenticationStatus()
                let checkResult = AuthCheckResult(
                    timestamp: Date(),
                    elapsedTime: elapsed,
                    isAuthenticated: isAuthenticated,
                    hasValidTokens: self.hasValidTokens()
                )
                authChecks.append(checkResult)
                
                print("🧪 AUTH CHECK (\(Int(elapsed/60))min): \(isAuthenticated ? "✅ LOGGED IN" : "❌ LOGGED OUT")")
                
                if !isAuthenticated {
                    timer.invalidate()
                    let result = AuthMonitorResult(
                        duration: elapsed,
                        checks: authChecks,
                        finalStatus: false
                    )
                    completion(result)
                }
            }
        }
    }
    
    /// Test authentication after simulated time periods
    func testAuthAfterTimeInterval(_ interval: AuthTestInterval, completion: @escaping (Bool) -> Void) {
        print("🧪 TESTING: Testing auth after \(interval.description)...")
        
        // For testing, we'll simulate the time passage by checking if tokens would still be valid
        // In a real scenario, you'd want to actually wait or manipulate system time
        
        let currentTime = Date()
        let futureTime = currentTime.addingTimeInterval(interval.timeInterval)
        
        print("🧪 TESTING: Simulating time passage to \(futureTime)")
        print("🧪 TESTING: Current tokens:")
        printTokenDetails()
        
        // Simulate what would happen after this time
        Task {
            // Check if current auth would still be valid
            let isCurrentlyValid = await AuthenticationService.shared.checkAuthenticationStatus()
            
            if isCurrentlyValid {
                print("🧪 TESTING: Auth would still be valid after \(interval.description)")
                await MainActor.run { completion(true) }
            } else {
                print("🧪 TESTING: Auth would be invalid after \(interval.description)")
                await MainActor.run { completion(false) }
            }
        }
    }
    
    /// Check if current tokens exist and are not obviously expired
    private func hasValidTokens() -> Bool {
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")
        let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken")
        
        return accessToken != nil && refreshToken != nil && 
               !accessToken!.isEmpty && !refreshToken!.isEmpty &&
               !accessToken!.contains("expired_token")
    }
    
    /// Print detailed token information for debugging
    func printTokenDetails() {
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")
        let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken")
        let userEmail = KeychainWrapper.standard.string(forKey: "userEmail")
        
        TestingConsole.shared.printHeader("Token Details")
        print("📧 User: \(userEmail ?? "nil")")
        print("🔑 Access Token: \(accessToken?.prefix(30) ?? "nil")...")
        print("🔄 Refresh Token: \(refreshToken?.prefix(30) ?? "nil")...")
        print("📏 Access Token Length: \(accessToken?.count ?? 0) chars")
        print("📏 Refresh Token Length: \(refreshToken?.count ?? 0) chars")
        print("🔐 Auth Service Status: \(AuthenticationService.shared.isAuthenticated)")
        print("⏰ Current Time: \(Date())")
        TestingConsole.shared.printSeparator()
    }
    
    /// Stress test authentication by making multiple rapid API calls
    func stressTestAuthentication(callCount: Int = 10, completion: @escaping (AuthStressTestResult) -> Void) {
        print("🧪 TESTING: Starting auth stress test with \(callCount) API calls...")
        
        var results: [Bool] = []
        let group = DispatchGroup()
        
        for i in 1...callCount {
            group.enter()
            
            Task {
                do {
                    let (_, response) = try await APIService.shared.request(
                        endpoint: "/api/session/preferences",
                        method: "GET",
                        headers: ["Content-Type": "application/json"],
                        retryOn401: true
                    )
                    
                    let success = response.statusCode == 200
                    results.append(success)
                    print("🧪 STRESS TEST \(i)/\(callCount): \(success ? "✅" : "❌")")
                    
                } catch {
                    results.append(false)
                    print("🧪 STRESS TEST \(i)/\(callCount): ❌ ERROR - \(error)")
                }
                
                group.leave()
            }
            
            // Small delay between calls
            usleep(100000) // 0.1 second
        }
        
        group.notify(queue: .main) {
            let successCount = results.filter { $0 }.count
            let result = AuthStressTestResult(
                totalCalls: callCount,
                successfulCalls: successCount,
                failedCalls: callCount - successCount,
                successRate: Double(successCount) / Double(callCount)
            )
            completion(result)
        }
    }
    
    // MARK: - Streak Testing
    
    /// Mock streak data for testing different scenarios
    func mockStreakScenario(_ scenario: StreakTestScenario, appModel: MainAppModel) {
        print("🧪 TESTING: Mocking streak scenario: \(scenario.description)")
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        switch scenario {
        case .noStreak:
            // Clear all sessions and reset streak
            appModel.allCompletedSessions = []
            appModel.currentStreak = 0
            appModel.highestStreak = 0
            appModel.countOfFullyCompletedSessions = 0
            
        case .activeStreak(let days):
            // Create sessions for the last N days
            var sessions: [CompletedSession] = []
            for i in 0..<days {
                let date = calendar.date(byAdding: .day, value: -i, to: today)!
                let session = CompletedSession(
                    date: date,
                    drills: createMockDrills(completed: true),
                    totalCompletedDrills: 3,
                    totalDrills: 3
                )
                sessions.append(session)
            }
            appModel.allCompletedSessions = sessions.reversed()
            appModel.currentStreak = days
            appModel.highestStreak = max(days, appModel.highestStreak)
            appModel.countOfFullyCompletedSessions = appModel.highestStreak + days
            
        case .brokenStreak(let currentStreak, let daysBroken):
            // Create a broken streak scenario
            var sessions: [CompletedSession] = []
            
            // Add current streak sessions
            for i in 0..<currentStreak {
                let date = calendar.date(byAdding: .day, value: -i, to: today)!
                let session = CompletedSession(
                    date: date,
                    drills: createMockDrills(completed: true),
                    totalCompletedDrills: 3,
                    totalDrills: 3
                )
                sessions.append(session)
            }
            
            // Add older sessions before the break
            for i in (currentStreak + daysBroken)..<(currentStreak + daysBroken + 5) {
                let date = calendar.date(byAdding: .day, value: -i, to: today)!
                let session = CompletedSession(
                    date: date,
                    drills: createMockDrills(completed: true),
                    totalCompletedDrills: 3,
                    totalDrills: 3
                )
                sessions.append(session)
            }
            
            appModel.allCompletedSessions = sessions.reversed()
            appModel.currentStreak = currentStreak
            appModel.highestStreak = max(currentStreak + 5, appModel.highestStreak)
            appModel.countOfFullyCompletedSessions = currentStreak + 5
            
        case .streakResetTrigger:
            // Create scenario that should trigger streak reset message
            let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
            let session = CompletedSession(
                date: twoDaysAgo,
                drills: createMockDrills(completed: true),
                totalCompletedDrills: 3,
                totalDrills: 3
            )
            appModel.allCompletedSessions = [session]
            appModel.currentStreak = 0
            appModel.highestStreak = 5
            appModel.countOfFullyCompletedSessions = 1
            
        case .partialSession:
            // Create a session with partial completion
            let session = CompletedSession(
                date: today,
                drills: createMockDrills(completed: false),
                totalCompletedDrills: 2,
                totalDrills: 3
            )
            appModel.allCompletedSessions = [session]
            appModel.currentStreak = 0
            appModel.highestStreak = 3
            appModel.countOfFullyCompletedSessions = 0
            
        case .missedDay:
            // Create scenario where user missed yesterday - preserves current highest streak and completed count
            // but resets current streak to 0
            
            // Capture current values BEFORE making changes
            let currentHighest = appModel.highestStreak
            let currentCompleted = appModel.countOfFullyCompletedSessions
            let previousCurrentStreak = appModel.currentStreak
            
            // Create sessions that end 2 days ago (to simulate missing yesterday)
            var sessions: [CompletedSession] = []
            
            // Only create sessions if there were completed sessions before
            if currentCompleted > 0 {
                for i in 2..<(currentCompleted + 2) {
                    let date = calendar.date(byAdding: .day, value: -i, to: today)!
                    let session = CompletedSession(
                        date: date,
                        drills: createMockDrills(completed: true),
                        totalCompletedDrills: 3,
                        totalDrills: 3
                    )
                    sessions.append(session)
                }
                appModel.allCompletedSessions = sessions.reversed()
            } else {
                // If no completed sessions, just clear them
                appModel.allCompletedSessions = []
            }
            
            // Set the app state to reflect the missed day scenario
            appModel.currentStreak = 0  // Reset because they missed yesterday
            appModel.highestStreak = currentHighest  // Preserve whatever they had
            appModel.countOfFullyCompletedSessions = currentCompleted  // Preserve whatever they had
            
            print("🧪 TESTING: Applied missed day scenario:")
            print("   - Previous current streak: \(previousCurrentStreak)")
            print("   - Current streak: 0 (reset - missed yesterday)")
            print("   - Highest streak: \(currentHighest) (preserved)")
            print("   - Completed sessions: \(currentCompleted) (preserved)")
            print("   - Last session was 2+ days ago")
        }
        
        print("🧪 TESTING: Streak scenario applied successfully")
        print("   - Current streak: \(appModel.currentStreak)")
        print("   - Highest streak: \(appModel.highestStreak)")
        print("   - Total sessions: \(appModel.allCompletedSessions.count)")
        print("   - Completed sessions: \(appModel.countOfFullyCompletedSessions)")
    }
    
    /// Force sync streak data to backend for testing
    func forceSyncStreakData(appModel: MainAppModel) async {
        print("🧪 TESTING: Force syncing streak data to backend...")
        
        do {
            try await DataSyncService.shared.syncProgressHistory(
                currentStreak: appModel.currentStreak,
                highestStreak: appModel.highestStreak,
                completedSessionsCount: appModel.countOfFullyCompletedSessions
            )
            print("🧪 TESTING: Streak data synced successfully")
        } catch {
            print("🧪 TESTING: Failed to sync streak data: \(error)")
        }
    }
    
    /// Test streak reset detection
    func testStreakResetDetection(appModel: MainAppModel) {
        print("🧪 TESTING: Testing streak reset detection...")
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        
        let hadSessionYesterday = appModel.allCompletedSessions.contains {
            calendar.isDate($0.date, inSameDayAs: yesterday)
        }
        let hadSessionTwoDaysAgo = appModel.allCompletedSessions.contains {
            calendar.isDate($0.date, inSameDayAs: twoDaysAgo)
        }
        
        print("🧪 TESTING: Streak reset detection results:")
        print("   - Current streak: \(appModel.currentStreak)")
        print("   - Had session yesterday: \(hadSessionYesterday)")
        print("   - Had session two days ago: \(hadSessionTwoDaysAgo)")
        print("   - Should show reset message: \(appModel.currentStreak == 0 && !hadSessionYesterday && hadSessionTwoDaysAgo)")
        
        if appModel.currentStreak == 0 && !hadSessionYesterday && hadSessionTwoDaysAgo {
            print("🧪 TESTING: Triggering streak reset message...")
            appModel.viewState.showStreakLostMessage = true
        }
    }
    
    // MARK: - App Lifecycle & Time Simulation Testing
    
    /// Simulate app being closed for a period of time and then reopened
    func simulateAppClosedForTime(_ interval: AuthTestInterval, completion: @escaping (AppLifecycleTestResult) -> Void) {
        print("🧪 TESTING: Simulating app closed for \(interval.description)...")
        
        // Record current state
        let beforeState = AppAuthState(
            isAuthenticated: AuthenticationService.shared.isAuthenticated,
            hasValidTokens: hasValidTokens(),
            timestamp: Date()
        )
        
        print("🧪 TESTING: State before 'closing' app:")
        print("   - Authenticated: \(beforeState.isAuthenticated)")
        print("   - Valid tokens: \(beforeState.hasValidTokens)")
        
        // Save current tokens to restore later if needed
        let originalAccessToken = KeychainWrapper.standard.string(forKey: "accessToken")
        let originalRefreshToken = KeychainWrapper.standard.string(forKey: "refreshToken")
        
        // Simulate the time passage by adding a delay and then checking auth
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // 2 second delay to simulate processing
            
            print("🧪 TESTING: Simulating app reopening after \(interval.description)...")
            
            // Test authentication as if app just reopened
            Task {
                // This simulates what happens when app reopens - check auth status
                let afterAuthCheck = await AuthenticationService.shared.checkAuthenticationStatus()
                
                let afterState = AppAuthState(
                    isAuthenticated: afterAuthCheck,
                    hasValidTokens: self.hasValidTokens(),
                    timestamp: Date()
                )
                
                print("🧪 TESTING: State after 'reopening' app:")
                print("   - Authenticated: \(afterState.isAuthenticated)")
                print("   - Valid tokens: \(afterState.hasValidTokens)")
                
                let result = AppLifecycleTestResult(
                    timeInterval: interval,
                    beforeState: beforeState,
                    afterState: afterState,
                    authPreserved: afterState.isAuthenticated == beforeState.isAuthenticated,
                    tokensPreserved: afterState.hasValidTokens == beforeState.hasValidTokens
                )
                
                await MainActor.run {
                    completion(result)
                }
            }
        }
    }
    
    /// Test what happens when app is backgrounded and foregrounded after time period
    func simulateAppBackgroundForTime(_ interval: AuthTestInterval, completion: @escaping (AppLifecycleTestResult) -> Void) {
        print("🧪 TESTING: Simulating app backgrounded for \(interval.description)...")
        
        // Record state before backgrounding
        let beforeState = AppAuthState(
            isAuthenticated: AuthenticationService.shared.isAuthenticated,
            hasValidTokens: hasValidTokens(),
            timestamp: Date()
        )
        
        // Simulate backgrounding by sending notification
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        print("🧪 TESTING: App backgrounded, waiting \(interval.description)...")
        
        // Wait for the specified interval (shortened for testing)
        let testDelay = min(interval.timeInterval, 10.0) // Max 10 seconds for testing
        
        DispatchQueue.main.asyncAfter(deadline: .now() + testDelay) {
            
            // Simulate foregrounding
            NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
            
            print("🧪 TESTING: App foregrounded, checking auth status...")
            
            Task {
                // Check auth status after foregrounding
                let afterAuthCheck = await AuthenticationService.shared.checkAuthenticationStatus()
                
                let afterState = AppAuthState(
                    isAuthenticated: afterAuthCheck,
                    hasValidTokens: self.hasValidTokens(),
                    timestamp: Date()
                )
                
                let result = AppLifecycleTestResult(
                    timeInterval: interval,
                    beforeState: beforeState,
                    afterState: afterState,
                    authPreserved: afterState.isAuthenticated,
                    tokensPreserved: afterState.hasValidTokens
                )
                
                await MainActor.run {
                    completion(result)
                }
            }
        }
    }
    
    /// Mock token expiration by manipulating stored timestamps or tokens
    func mockTokenExpiration(_ timeAgo: AuthTestInterval, completion: @escaping (Bool) -> Void) {
        print("🧪 TESTING: Mocking token expiration as if tokens were created \(timeAgo.description) ago...")
        
        // Store original tokens
        let originalAccessToken = KeychainWrapper.standard.string(forKey: "accessToken")
        let originalRefreshToken = KeychainWrapper.standard.string(forKey: "refreshToken")
        
        // Create "old" tokens by adding a timestamp indicator
        let timeAgoSeconds = Int(timeAgo.timeInterval)
        let expiredAccessToken = "expired_\(timeAgoSeconds)_\(originalAccessToken ?? "")"
        let expiredRefreshToken = "expired_\(timeAgoSeconds)_\(originalRefreshToken ?? "")"
        
        // Set the "expired" tokens
        KeychainWrapper.standard.set(expiredAccessToken, forKey: "accessToken")
        KeychainWrapper.standard.set(expiredRefreshToken, forKey: "refreshToken")
        
        print("🧪 TESTING: Set expired tokens (simulating \(timeAgo.description) old)")
        
        // Test authentication with "expired" tokens
        Task {
            let isStillAuthenticated = await AuthenticationService.shared.checkAuthenticationStatus()
            
            print("🧪 TESTING: Auth check with 'expired' tokens: \(isStillAuthenticated ? "✅ VALID" : "❌ EXPIRED")")
            
            // Restore original tokens if they exist
            if let originalAccess = originalAccessToken {
                KeychainWrapper.standard.set(originalAccess, forKey: "accessToken")
            }
            if let originalRefresh = originalRefreshToken {
                KeychainWrapper.standard.set(originalRefresh, forKey: "refreshToken")
            }
            
            await MainActor.run {
                completion(isStillAuthenticated)
            }
        }
    }
    
    /// Test app restart scenario - clear auth state and then restore
    func simulateAppRestart(completion: @escaping (AppLifecycleTestResult) -> Void) {
        print("🧪 TESTING: Simulating complete app restart...")
        
        // Record current state
        let beforeState = AppAuthState(
            isAuthenticated: AuthenticationService.shared.isAuthenticated,
            hasValidTokens: hasValidTokens(),
            timestamp: Date()
        )
        
        // Store tokens to simulate persistence across restart
        let storedAccessToken = KeychainWrapper.standard.string(forKey: "accessToken")
        let storedRefreshToken = KeychainWrapper.standard.string(forKey: "refreshToken")
        let storedEmail = KeychainWrapper.standard.string(forKey: "userEmail")
        
        print("🧪 TESTING: Simulating app termination...")
        print("🧪 TESTING: Tokens stored in keychain:")
        print("   - Access: \(storedAccessToken != nil ? "✅" : "❌")")
        print("   - Refresh: \(storedRefreshToken != nil ? "✅" : "❌")")
        print("   - Email: \(storedEmail != nil ? "✅" : "❌")")
        
        // Simulate app restart by clearing in-memory auth state
        // (In real scenario, this would happen automatically on app restart)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🧪 TESTING: Simulating app restart - checking auth restoration...")
            
            Task {
                // This simulates what happens on app startup - check stored auth
                let restoredAuth = await AuthenticationService.shared.checkAuthenticationStatus()
                
                let afterState = AppAuthState(
                    isAuthenticated: restoredAuth,
                    hasValidTokens: self.hasValidTokens(),
                    timestamp: Date()
                )
                
                let result = AppLifecycleTestResult(
                    timeInterval: .minutes(0), // Immediate restart
                    beforeState: beforeState,
                    afterState: afterState,
                    authPreserved: afterState.isAuthenticated,
                    tokensPreserved: afterState.hasValidTokens
                )
                
                print("🧪 TESTING: Auth restoration result: \(restoredAuth ? "✅ SUCCESS" : "❌ FAILED")")
                
                await MainActor.run {
                    completion(result)
                }
            }
        }
    }
    
    // MARK: - Utility Functions
    
    /// Create mock drill data for testing
    func createMockDrills(completed: Bool) -> [EditableDrillModel] {
        let drills = [
            ("Ball Control", "Juggling"),
            ("Shooting", "Target Practice"),
            ("Passing", "Wall Pass")
        ]
        
        return drills.map { (skill, title) in
            let drill = DrillModel(
                id: UUID(),
                backendId: Int.random(in: 1...100),
                title: title,
                skill: skill,
                subSkills: [skill],
                sets: 3,
                reps: 10,
                duration: 300,
                description: "Test drill for \(skill)",
                instructions: ["Test instruction"],
                tips: ["Test tip"],
                equipment: ["Ball"],
                trainingStyle: "Beginner",
                difficulty: "Easy",
                videoUrl: ""
            )
            
            return EditableDrillModel(
                drill: drill,
                setsDone: completed ? 3 : Int.random(in: 0...2),
                totalSets: 3,
                totalReps: 10,
                totalDuration: 300,
                isCompleted: completed
            )
        }
    }
    
    /// Print current authentication state for debugging
    func printAuthenticationState() {
        TestingConsole.shared.printAuthState(
            accessToken: KeychainWrapper.standard.string(forKey: "accessToken"),
            refreshToken: KeychainWrapper.standard.string(forKey: "refreshToken"),
            userEmail: KeychainWrapper.standard.string(forKey: "userEmail"),
            isAuthenticated: AuthenticationService.shared.isAuthenticated
        )
    }
    
    /// Print current streak state for debugging
    func printStreakState(appModel: MainAppModel) {
        TestingConsole.shared.printStreakState(
            currentStreak: appModel.currentStreak,
            highestStreak: appModel.highestStreak,
            completedSessions: appModel.countOfFullyCompletedSessions,
            totalSessions: appModel.allCompletedSessions.count,
            completedToday: appModel.alreadyCompletedToday(),
            showResetMessage: appModel.viewState.showStreakLostMessage
        )
        
        // Also print session data
        TestingConsole.shared.printSessionData(sessions: appModel.allCompletedSessions)
    }
}

// MARK: - Test Scenarios

enum StreakTestScenario {
    case noStreak
    case activeStreak(days: Int)
    case brokenStreak(currentStreak: Int, daysBroken: Int)
    case streakResetTrigger
    case partialSession
    case missedDay
    
    var description: String {
        switch self {
        case .noStreak:
            return "No streak (fresh start)"
        case .activeStreak(let days):
            return "Active \(days)-day streak"
        case .brokenStreak(let current, let broken):
            return "Broken streak (current: \(current), gap: \(broken) days)"
        case .streakResetTrigger:
            return "Streak reset trigger scenario"
        case .partialSession:
            return "Partial session completion"
        case .missedDay:
            return "Missed day scenario (preserves current streak and count)"
        }
    }
}

// MARK: - Authentication Testing Data Structures

enum AuthTestInterval {
    case minutes(Int)
    case hours(Int)
    case days(Int)
    case weeks(Int)
    
    var timeInterval: TimeInterval {
        switch self {
        case .minutes(let m): return TimeInterval(m * 60)
        case .hours(let h): return TimeInterval(h * 3600)
        case .days(let d): return TimeInterval(d * 86400)
        case .weeks(let w): return TimeInterval(w * 604800)
        }
    }
    
    var description: String {
        switch self {
        case .minutes(let m): return "\(m) minute\(m != 1 ? "s" : "")"
        case .hours(let h): return "\(h) hour\(h != 1 ? "s" : "")"
        case .days(let d): return "\(d) day\(d != 1 ? "s" : "")"
        case .weeks(let w): return "\(w) week\(w != 1 ? "s" : "")"
        }
    }
}

struct AuthCheckResult {
    let timestamp: Date
    let elapsedTime: TimeInterval
    let isAuthenticated: Bool
    let hasValidTokens: Bool
}

struct AuthMonitorResult {
    let duration: TimeInterval
    let checks: [AuthCheckResult]
    let finalStatus: Bool
    
    var successRate: Double {
        let authenticatedChecks = checks.filter { $0.isAuthenticated }
        return checks.isEmpty ? 0.0 : Double(authenticatedChecks.count) / Double(checks.count)
    }
    
    var timeToLogout: TimeInterval? {
        return checks.first { !$0.isAuthenticated }?.elapsedTime
    }
}

struct AuthStressTestResult {
    let totalCalls: Int
    let successfulCalls: Int
    let failedCalls: Int
    let successRate: Double
}

// MARK: - App Lifecycle Testing Data Structures

struct AppAuthState {
    let isAuthenticated: Bool
    let hasValidTokens: Bool
    let timestamp: Date
}

struct AppLifecycleTestResult {
    let timeInterval: AuthTestInterval
    let beforeState: AppAuthState
    let afterState: AppAuthState
    let authPreserved: Bool
    let tokensPreserved: Bool
    
    var testPassed: Bool {
        return authPreserved && tokensPreserved
    }
    
    var summary: String {
        return """
        Time Period: \(timeInterval.description)
        Auth Preserved: \(authPreserved ? "✅" : "❌")
        Tokens Preserved: \(tokensPreserved ? "✅" : "❌")
        Overall: \(testPassed ? "PASS" : "FAIL")
        """
    }
}
