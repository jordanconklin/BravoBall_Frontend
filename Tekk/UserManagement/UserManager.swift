//
//  UserManager.swift
//  BravoBall
//
//  Created by Joshua Conklin on 3/10/25.
//

import Foundation
import SwiftUI
import SwiftKeychainWrapper


class UserManager: ObservableObject {
    @Published var userId: Int = 0
    @Published var email: String = ""
    @Published var accessToken: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var userHasAccountHistory: Bool = false
    @Published var showLoginPage = false
    @Published var showWelcome = false
    @Published var showIntroAnimation = true
    
    private let keychain = KeychainWrapper.standard
    
    init() {
        restoreLoginStateFromStorage()
    }
    
    // Updates the currentUser instance of User structure
    func updateUserKeychain(email: String) {
        
        // Store in Keychain
        keychain.set(email, forKey: "userEmail")
        
        print("✅ User data saved to Keychain")
        print("Email: \(email)")
    }
    
    func clearUserKeychain() {
        // Clear Keychain
        keychain.removeObject(forKey: "userEmail")
        
        print("✅ User data cleared from Keychain")
    }
    
    // Returns tuple of user info from () -> its types, must be in same order
    func getUserFromKeychain() -> String {
        let email = KeychainWrapper.standard.string(forKey: "userEmail") ?? ""
        return email
    }
    
    func saveUserData() {
        // Save user data to UserDefaults
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(email, forKey: "email")
        
        // Save access token to Keychain for better security
        KeychainWrapper.standard.set(accessToken, forKey: "accessToken")
        
        // Update login state
        isLoggedIn = !accessToken.isEmpty
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
    }
    
    func restoreLoginStateFromStorage() {
        // Load user data from UserDefaults
        userId = UserDefaults.standard.integer(forKey: "userId")
        email = UserDefaults.standard.string(forKey: "email") ?? ""
        
        // Load access token from Keychain
        accessToken = KeychainWrapper.standard.string(forKey: "accessToken") ?? ""
        
        // Also load email from keychain (this is the primary source)
        let keychainEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? ""
        if !keychainEmail.isEmpty {
            email = keychainEmail
        }
        
        // Update login state - user is logged in if they have both email and access token
        isLoggedIn = !accessToken.isEmpty && !email.isEmpty
        userHasAccountHistory = isLoggedIn
        
        // Update UserDefaults to reflect current state
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        
        print("📱 UserManager loaded data - Email: \(email), isLoggedIn: \(isLoggedIn)")
    }
    
    
    func logout() {
        print("\n👋 User logging out...")
        
        // Store previous email for logging purposes
        let previousEmail = email
        
        // Clear user data
        userId = 0
        email = ""
        accessToken = ""
        isLoggedIn = false
        userHasAccountHistory = false
    
        // Remove from UserDefaults and Keychain
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "refreshToken")
        KeychainWrapper.standard.removeObject(forKey: "userEmail")
        
        // Clear user-specific liked drills UUID
        UserDefaults.standard.removeObject(forKey: "\(previousEmail)_likedDrillsUUID")
        
        // Clear user cache to ensure all data is properly removed
        CacheManager.shared.clearUserCache()
        
        // Reset last active user to force clearing in next initialization
        UserDefaults.standard.removeObject(forKey: "lastActiveUser")
        
        // Post a notification that user has logged out so all views can update
        NotificationCenter.default.post(
            name: Notification.Name("UserLoggedOut"),
            object: nil,
            userInfo: ["previousEmail": previousEmail]
        )
        
        print("✅ User data cleared from all storage")
    }
    
    func resetUserStateAfterOnboarding() {
        // Reset published properties after onboarding
        showLoginPage = false
        showWelcome = false
        accessToken = ""

        print("auth token nil value: \(accessToken)")
    }

    
    /// Clears login state and stored tokens
    func clearLoginState() {
        isLoggedIn = false
        accessToken = ""
        showLoginPage = false
        showWelcome = false
        showIntroAnimation = false
        
        // Clear stored tokens
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "refreshToken")
        KeychainWrapper.standard.removeObject(forKey: "userEmail")
        
        print("🧹 Cleared login state and stored tokens")
    }
    
    // Fetch and set user data
    func loadBackendData(appModel: MainAppModel, sessionModel: SessionGeneratorModel) async {
        print("\n🚀 ===== STARTING loadBackendData() =====")
        print("📅 Timestamp: \(Date())")
        
        print("\n📱 Loading cached data for current user...")
        let userEmail = KeychainWrapper.standard.string(forKey: "userEmail") ?? "no user"
        print("\n👤 USER SESSION INFO:")
        print("----------------------------------------")
        print("Current user email: \(userEmail)")
        print("isInitialLoad: \(sessionModel.isInitialLoad)")
        print("isLoggingOut: \(sessionModel.isLoggingOut)")
        
        // If no user is logged in or changing users, ensure we don't load old data
        if userEmail == "no user" {
            print("⚠️ No valid user found, clearing any existing data")
            sessionModel.clearUserData()
            print("❌ loadBackendData() EXITING - No user found")
            return
        }
        
        print("✅ User validation passed")
        sessionModel.isInitialLoad = true
        appModel.isInitialLoad = true
        print("✅ Set isInitialLoad = true")
        
        print("\n🔄 Starting backend data fetch with task group...")
        
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                print("📦 Task group created successfully")
                
                // ordered drills
                print("\n📋 Adding ordered drills task...")
                group.addTask {
                    print("🔄 [TASK] Starting ordered drills fetch...")
                    let backendDrills = try await DataSyncService.shared.fetchOrderedDrills()
                    print("✅ [TASK] Successfully fetched \(backendDrills.count) ordered drills from backend")
                    
                    await MainActor.run {
                        print("🔄 [MAIN] Updating orderedSessionDrills on main thread...")
                        print("📊 [MAIN] Previous count: \(sessionModel.orderedSessionDrills.count)")
                        sessionModel.orderedSessionDrills = backendDrills
                        print("📊 [MAIN] New count: \(sessionModel.orderedSessionDrills.count)")
                        print("✅ [MAIN] orderedSessionDrills updated successfully")
                    }
                }
                
                // completed sessions

                group.addTask {

                    let backendSessions = try await DataSyncService.shared.fetchCompletedSessions()

                    
                    await MainActor.run {
                        
                        appModel.allCompletedSessions = backendSessions
                        
                    }
                }
                

                
                // progress history
                group.addTask {

                    let progressHistory = try await DataSyncService.shared.fetchProgressHistory()
                    
                    await MainActor.run {

                        
                        appModel.currentStreak = progressHistory.currentStreak
                        appModel.highestStreak = progressHistory.highestStreak
                        appModel.countOfFullyCompletedSessions = progressHistory.completedSessionsCount
                        
                        print("✅ [MAIN] Progress history updated successfully")
                    }
                }
                
                // saved filters
                print("\n📋 Adding saved filters task...")
                group.addTask {
                    print("🔄 [TASK] Starting saved filters fetch...")
                    let backendFilters = try await SavedFiltersService.shared.fetchSavedFilters()
                    print("✅ [TASK] Successfully fetched \(backendFilters.count) saved filters from backend")
                    
                    await MainActor.run {
                        print("🔄 [MAIN] Updating allSavedFilters on main thread...")
                        print("📊 [MAIN] Previous count: \(sessionModel.allSavedFilters.count)")
                        sessionModel.allSavedFilters = backendFilters
                        print("📊 [MAIN] New count: \(sessionModel.allSavedFilters.count)")
                        print("✅ [MAIN] allSavedFilters updated successfully")
                    }
                }
                
                // drill groups
                print("\n📋 Adding drill groups task...")
                group.addTask {
                    print("🔄 [TASK] Starting drill groups fetch...")
                    print("⚠️ [TASK] Note: loadDrillGroupsFromBackend() updates UI directly (not in MainActor)")
                    
                    try await sessionModel.loadDrillGroupsFromBackend()
                    
                    print("✅ [TASK] Drill groups loaded successfully")
                    print("📊 [TASK] Final counts:")
                    print("   - Saved drills: \(sessionModel.savedDrills.count)")
                    print("   - Liked drills: \(sessionModel.likedDrillsGroup.drills.count)")
                    print("   - Group backend IDs: \(sessionModel.groupBackendIds.count)")
                }
                
                // preferences
                print("\n📋 Adding preferences task...")
                group.addTask {
                    print("🔄 [TASK] Starting preferences fetch...")
                    let preferences = try await PreferencesUpdateService.shared.fetchPreferences()
                    print("✅ [TASK] Successfully fetched preferences from backend")
                    print("📊 [TASK] Preferences data:")
                    print("   - Duration: \(preferences.duration ?? 0)")
                    print("   - Equipment: \(preferences.availableEquipment ?? [])")
                    print("   - Training style: \(preferences.trainingStyle ?? "nil")")
                    print("   - Location: \(preferences.trainingLocation ?? "nil")")
                    print("   - Difficulty: \(preferences.difficulty ?? "nil")")
                    print("   - Target skills: \(preferences.targetSkills ?? [])")
                    
                    await MainActor.run {
                        print("🔄 [MAIN] Updating preferences on main thread...")
                        
                        // Convert duration to time string
                        sessionModel.selectedTime = PreferencesUpdateService.shared.convertMinutesToTimeString(preferences.duration ?? 0)
                        print("📊 [MAIN] selectedTime: \(sessionModel.selectedTime ?? "nil")")
                        
                        // Update equipment
                        sessionModel.selectedEquipment = Set(preferences.availableEquipment ?? [])
                        print("📊 [MAIN] selectedEquipment: \(sessionModel.selectedEquipment)")
                        
                        // Update other preferences
                        sessionModel.selectedTrainingStyle = preferences.trainingStyle
                        print("📊 [MAIN] selectedTrainingStyle: \(sessionModel.selectedTrainingStyle ?? "nil")")

                        sessionModel.selectedLocation = preferences.trainingLocation
                        print("📊 [MAIN] selectedLocation: \(sessionModel.selectedLocation ?? "nil")")

                        sessionModel.selectedDifficulty = preferences.difficulty
                        print("📊 [MAIN] selectedDifficulty: \(sessionModel.selectedDifficulty ?? "nil")")
                        
                        // Convert backend skills to frontend format
                        sessionModel.selectedSkills = Set(preferences.targetSkills ?? [])
                        print("📊 [MAIN] selectedSkills: \(sessionModel.selectedSkills)")
                        
                        print("✅ [MAIN] All preferences updated successfully")
                    }
                }
                
                print("\n⏳ Waiting for all remaining tasks to complete...")
                try await group.waitForAll()
                print("✅ All tasks completed successfully")
                sessionModel.isInitialLoad = false
                appModel.isInitialLoad = false
                print("✅ Set isInitialLoad = false")
            }
            
            print("\n🎉 ===== loadBackendData() COMPLETED SUCCESSFULLY =====")
            print("📊 Final data summary:")
            print("   - Ordered drills: \(sessionModel.orderedSessionDrills.count)")
            print("   - Completed sessions: \(appModel.allCompletedSessions.count)")
            print("   - Current streak: \(appModel.currentStreak)")
            print("   - Saved filters: \(sessionModel.allSavedFilters.count)")
            print("   - Saved drill groups: \(sessionModel.savedDrills.count)")
            print("   - Liked drills: \(sessionModel.likedDrillsGroup.drills.count)")
            print("   - Selected skills: \(sessionModel.selectedSkills)")
            
            } catch {
            print("\n❌ ===== loadBackendData() FAILED =====")
            print("Error fetching user's data: \(error)")
                    print("Error type: \(type(of: error))")
                    print("Error description: \(error.localizedDescription)")
            
            if let decodingError = error as? DecodingError {
                print("🔍 Decoding error details:")
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("   - Missing key: \(key)")
                    print("   - Context: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("   - Type mismatch: expected \(type)")
                    print("   - Context: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("   - Value not found for type: \(type)")
                    print("   - Context: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("   - Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("   - Unknown decoding error")
        }
    }
}
        
        print("\n🏁 ===== loadBackendData() ENDED =====")
    }
}
