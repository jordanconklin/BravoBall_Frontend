//
//  TestingConsole.swift
//  BravoBall
//
//  Created by Testing Assistant on 1/15/25.
//

import Foundation

/// A simple console utility for better testing output
class TestingConsole {
    static let shared = TestingConsole()
    
    private init() {}
    
    /// Print a test header
    func printHeader(_ title: String) {
        print("\n" + "="*60)
        print("🧪 \(title.uppercased())")
        print("="*60)
    }
    
    /// Print a test step
    func printStep(_ step: String) {
        print("📋 \(step)")
    }
    
    /// Print a test result
    func printResult(_ result: String, success: Bool) {
        let emoji = success ? "✅" : "❌"
        print("\(emoji) \(result)")
    }
    
    /// Print authentication state in a formatted way
    func printAuthState(
        accessToken: String?,
        refreshToken: String?,
        userEmail: String?,
        isAuthenticated: Bool
    ) {
        printHeader("Authentication State")
        print("📧 User Email: \(userEmail ?? "nil")")
        print("🔑 Access Token: \(accessToken?.prefix(20) ?? "nil")...")
        print("🔄 Refresh Token: \(refreshToken?.prefix(20) ?? "nil")...")
        print("🔐 Is Authenticated: \(isAuthenticated)")
        print("-" * 60)
    }
    
    /// Print streak state in a formatted way
    func printStreakState(
        currentStreak: Int,
        highestStreak: Int,
        completedSessions: Int,
        totalSessions: Int,
        completedToday: Bool,
        showResetMessage: Bool
    ) {
        printHeader("Streak State")
        print("🔥 Current Streak: \(currentStreak) days")
        print("🏆 Highest Streak: \(highestStreak) days")
        print("📊 Completed Sessions: \(completedSessions)")
        print("📈 Total Sessions: \(totalSessions)")
        print("📅 Completed Today: \(completedToday ? "Yes" : "No")")
        print("⚠️ Show Reset Message: \(showResetMessage ? "Yes" : "No")")
        print("-" * 60)
    }
    
    /// Print API response info
    func printAPIResponse(endpoint: String, statusCode: Int, success: Bool) {
        printHeader("API Response")
        print("🌐 Endpoint: \(endpoint)")
        print("📊 Status Code: \(statusCode)")
        printResult("Request \(success ? "successful" : "failed")", success: success)
        print("-" * 60)
    }
    
    /// Print session data
    func printSessionData(sessions: [CompletedSession]) {
        printHeader("Session Data")
        print("📊 Total Sessions: \(sessions.count)")
        
        if sessions.isEmpty {
            print("📭 No sessions found")
        } else {
            print("📋 Recent Sessions:")
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            
            for (index, session) in sessions.suffix(5).enumerated() {
                let completion = Double(session.totalCompletedDrills) / Double(session.totalDrills)
                let percentage = Int(completion * 100)
                print("   \(index + 1). \(dateFormatter.string(from: session.date)): \(session.totalCompletedDrills)/\(session.totalDrills) (\(percentage)%)")
            }
        }
        print("-" * 60)
    }
    
    /// Print a simple separator
    func printSeparator() {
        print("-" * 60)
    }
}

// String multiplication extension for console formatting
extension String {
    static func * (string: String, count: Int) -> String {
        return String(repeating: string, count: count)
    }
}
