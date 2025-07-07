//
//  TestingView.swift
//  BravoBall
//
//  Created by Testing Assistant on 1/15/25.
//

import SwiftUI

struct TestingView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @ObservedObject var userManager: UserManager
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var isTestingTokenRefresh = false
    
    let globalSettings = GlobalSettings.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🧪 Testing Tools")
                            .font(.custom("Poppins-Bold", size: 24))
                            .foregroundColor(globalSettings.primaryDarkColor)
                        
                        Text("Debug tools for testing authentication and streak scenarios")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(globalSettings.primaryGrayColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Authentication Testing Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("🔐 Authentication Testing")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundColor(globalSettings.primaryDarkColor)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            TestingButton(
                                title: "Mock Expired Access Token",
                                subtitle: "Test 401 handling",
                                color: globalSettings.primaryPurpleColor,
                                action: {
                                    TestingService.shared.mockExpiredAccessToken()
                                    showAlert(title: "Token Mocked", message: "Access token has been set to expired. Try making a request to test refresh flow.")
                                }
                            )
                            
                            TestingButton(
                                title: "Mock Invalid Refresh Token",
                                subtitle: "Test logout scenario",
                                color: globalSettings.primaryPurpleColor,
                                action: {
                                    TestingService.shared.mockInvalidRefreshToken()
                                    showAlert(title: "Refresh Token Mocked", message: "Refresh token has been set to invalid. User should be logged out on next API call.")
                                }
                            )
                            
                            TestingButton(
                                title: "Mock Both Tokens Expired",
                                subtitle: "Force logout",
                                color: globalSettings.primaryPurpleColor,
                                action: {
                                    TestingService.shared.mockBothTokensExpired()
                                    showAlert(title: "Both Tokens Mocked", message: "Both tokens are now invalid. User should be logged out immediately.")
                                }
                            )
                            
                            TestingButton(
                                title: "Test Token Refresh",
                                subtitle: isTestingTokenRefresh ? "Testing..." : "Full refresh flow",
                                color: globalSettings.primaryLightBlueColor,
                                action: {
                                    testTokenRefresh()
                                },
                                disabled: isTestingTokenRefresh
                            )
                        }
                        
                        TestingButton(
                            title: "Print Auth State",
                            subtitle: "Debug current tokens",
                            color: globalSettings.primaryGrayColor,
                            action: {
                                TestingService.shared.printAuthenticationState()
                                showAlert(title: "Auth State", message: "Check console for detailed authentication state info.")
                            }
                        )
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Authentication Persistence Testing Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("⏰ Authentication Persistence Testing")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundColor(globalSettings.primaryDarkColor)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            TestingButton(
                                title: "Token Details",
                                subtitle: "Show token info & expiration",
                                color: globalSettings.primaryLightBlueColor,
                                action: {
                                    TestingService.shared.printTokenDetails()
                                    showAlert(title: "Token Details", message: "Check console for detailed token information.")
                                }
                            )
                            
                            TestingButton(
                                title: "1 Hour Monitor",
                                subtitle: "Check auth every 5min",
                                color: Color.green,
                                action: {
                                    TestingService.shared.startAuthenticationMonitor(duration: 3600) { result in
                                        let message = """
                                        Monitor completed!
                                        Duration: \(Int(result.duration/60)) minutes
                                        Success rate: \(Int(result.successRate * 100))%
                                        Final status: \(result.finalStatus ? "Logged in" : "Logged out")
                                        """
                                        showAlert(title: "Auth Monitor Results", message: message)
                                    }
                                    showAlert(title: "Monitor Started", message: "Authentication monitor started. Will check every 5 minutes for 1 hour.")
                                }
                            )
                            
                            TestingButton(
                                title: "30-Min Monitor",
                                subtitle: "Quick auth test",
                                color: Color.green.opacity(0.8),
                                action: {
                                    TestingService.shared.startAuthenticationMonitor(duration: 1800) { result in
                                        let message = """
                                        Monitor completed!
                                        Duration: \(Int(result.duration/60)) minutes
                                        Success rate: \(Int(result.successRate * 100))%
                                        Final status: \(result.finalStatus ? "Logged in" : "Logged out")
                                        """
                                        showAlert(title: "Auth Monitor Results", message: message)
                                    }
                                    showAlert(title: "Monitor Started", message: "Authentication monitor started. Will check every 5 minutes for 30 minutes.")
                                }
                            )
                            
                            TestingButton(
                                title: "Stress Test",
                                subtitle: "10 rapid API calls",
                                color: Color.red,
                                action: {
                                    TestingService.shared.stressTestAuthentication(callCount: 10) { result in
                                        let message = """
                                        Stress test completed!
                                        Total calls: \(result.totalCalls)
                                        Successful: \(result.successfulCalls)
                                        Failed: \(result.failedCalls)
                                        Success rate: \(Int(result.successRate * 100))%
                                        """
                                        showAlert(title: "Stress Test Results", message: message)
                                    }
                                    showAlert(title: "Stress Test Started", message: "Making 10 rapid API calls to test authentication stability...")
                                }
                            )
                        }
                        
                        // Time interval tests
                        VStack(spacing: 10) {
                            Text("Test Auth After Time Periods:")
                                .font(.custom("Poppins-Bold", size: 14))
                                .foregroundColor(globalSettings.primaryDarkColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                TestingButton(
                                    title: "1 Hour",
                                    subtitle: "Auth check",
                                    color: Color.blue,
                                    action: {
                                        TestingService.shared.testAuthAfterTimeInterval(.hours(1)) { isValid in
                                            showAlert(
                                                title: "1 Hour Auth Test",
                                                message: isValid ? "Auth would still be valid after 1 hour" : "Auth would be invalid after 1 hour"
                                            )
                                        }
                                    }
                                )
                                
                                TestingButton(
                                    title: "6 Hours",
                                    subtitle: "Auth check",
                                    color: Color.blue.opacity(0.8),
                                    action: {
                                        TestingService.shared.testAuthAfterTimeInterval(.hours(6)) { isValid in
                                            showAlert(
                                                title: "6 Hour Auth Test",
                                                message: isValid ? "Auth would still be valid after 6 hours" : "Auth would be invalid after 6 hours"
                                            )
                                        }
                                    }
                                )
                                
                                TestingButton(
                                    title: "1 Day",
                                    subtitle: "Auth check",
                                    color: Color.purple,
                                    action: {
                                        TestingService.shared.testAuthAfterTimeInterval(.days(1)) { isValid in
                                            showAlert(
                                                title: "1 Day Auth Test",
                                                message: isValid ? "Auth would still be valid after 1 day" : "Auth would be invalid after 1 day"
                                            )
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // App Lifecycle Testing Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📱 App Lifecycle Testing")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundColor(globalSettings.primaryDarkColor)
                        
                        Text("Test what happens when app is closed, backgrounded, or reopened after time periods")
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(globalSettings.primaryGrayColor)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            TestingButton(
                                title: "App Closed 1 Day",
                                subtitle: "Simulate day-long closure",
                                color: Color.purple,
                                action: {
                                    TestingService.shared.simulateAppClosedForTime(.days(1)) { result in
                                        showAlert(title: "App Closed Test", message: result.summary)
                                    }
                                }
                            )
                            
                            TestingButton(
                                title: "App Closed 6 Hours",
                                subtitle: "Simulate long closure",
                                color: Color.purple.opacity(0.8),
                                action: {
                                    TestingService.shared.simulateAppClosedForTime(.hours(6)) { result in
                                        showAlert(title: "App Closed Test", message: result.summary)
                                    }
                                }
                            )
                            
                            TestingButton(
                                title: "Backgrounded 1 Hour",
                                subtitle: "App in background",
                                color: Color.indigo,
                                action: {
                                    TestingService.shared.simulateAppBackgroundForTime(.hours(1)) { result in
                                        showAlert(title: "Background Test", message: result.summary)
                                    }
                                }
                            )
                            
                            TestingButton(
                                title: "App Restart",
                                subtitle: "Complete restart test",
                                color: Color.brown,
                                action: {
                                    TestingService.shared.simulateAppRestart { result in
                                        showAlert(title: "Restart Test", message: result.summary)
                                    }
                                }
                            )
                        }
                        
                        // Token expiration testing
                        VStack(spacing: 10) {
                            Text("🕐 Mock Token Expiration:")
                                .font(.custom("Poppins-Bold", size: 14))
                                .foregroundColor(globalSettings.primaryDarkColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                TestingButton(
                                    title: "1 Day Old",
                                    subtitle: "Expired tokens",
                                    color: Color.red.opacity(0.7),
                                    action: {
                                        TestingService.shared.mockTokenExpiration(.days(1)) { isValid in
                                            showAlert(
                                                title: "Token Expiration Test",
                                                message: isValid ? "❌ Tokens should be expired but are still valid" : "✅ Tokens correctly expired after 1 day"
                                            )
                                        }
                                    }
                                )
                                
                                TestingButton(
                                    title: "6 Hours Old",
                                    subtitle: "Token age test",
                                    color: Color.orange.opacity(0.7),
                                    action: {
                                        TestingService.shared.mockTokenExpiration(.hours(6)) { isValid in
                                            showAlert(
                                                title: "Token Expiration Test",
                                                message: isValid ? "✅ Tokens still valid after 6 hours" : "❌ Tokens expired too quickly (6 hours)"
                                            )
                                        }
                                    }
                                )
                                
                                TestingButton(
                                    title: "1 Week Old",
                                    subtitle: "Very old tokens",
                                    color: Color.red,
                                    action: {
                                        TestingService.shared.mockTokenExpiration(.weeks(1)) { isValid in
                                            showAlert(
                                                title: "Token Expiration Test",
                                                message: isValid ? "❌ Week-old tokens should definitely be expired" : "✅ Week-old tokens correctly expired"
                                            )
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Streak Testing Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("🔥 Streak Testing")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundColor(globalSettings.primaryDarkColor)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            TestingButton(
                                title: "No Streak",
                                subtitle: "Reset to 0",
                                color: globalSettings.primaryGrayColor,
                                action: {
                                    TestingService.shared.mockStreakScenario(.noStreak, appModel: appModel)
                                    showAlert(title: "Streak Reset", message: "Streak has been reset to 0 with no sessions.")
                                }
                            )
                            
                            TestingButton(
                                title: "7-Day Streak",
                                subtitle: "Active streak",
                                color: globalSettings.primaryYellowColor,
                                action: {
                                    TestingService.shared.mockStreakScenario(.activeStreak(days: 7), appModel: appModel)
                                    showAlert(title: "Streak Set", message: "7-day active streak has been created.")
                                }
                            )
                            
                            TestingButton(
                                title: "Broken Streak",
                                subtitle: "3 days, 1 gap",
                                color: globalSettings.primaryLightBlueColor,
                                action: {
                                    TestingService.shared.mockStreakScenario(.brokenStreak(currentStreak: 3, daysBroken: 1), appModel: appModel)
                                    showAlert(title: "Broken Streak", message: "Streak broken with 3 current days and 1-day gap.")
                                }
                            )
                            
                            TestingButton(
                                title: "Streak Reset Trigger",
                                subtitle: "Show reset message",
                                color: globalSettings.primaryPurpleColor,
                                action: {
                                    TestingService.shared.mockStreakScenario(.streakResetTrigger, appModel: appModel)
                                    TestingService.shared.testStreakResetDetection(appModel: appModel)
                                    showAlert(title: "Reset Triggered", message: "Streak reset scenario created. Check if reset message appears.")
                                }
                            )
                            
                            TestingButton(
                                title: "Partial Session",
                                subtitle: "Incomplete today",
                                color: globalSettings.primaryGrayColor,
                                action: {
                                    TestingService.shared.mockStreakScenario(.partialSession, appModel: appModel)
                                    showAlert(title: "Partial Session", message: "Today's session is partially complete (2/3 drills).")
                                }
                            )
                            
                            TestingButton(
                                title: "30-Day Streak",
                                subtitle: "Long streak",
                                color: globalSettings.primaryGreenColor,
                                action: {
                                    TestingService.shared.mockStreakScenario(.activeStreak(days: 30), appModel: appModel)
                                    showAlert(title: "Long Streak", message: "30-day active streak has been created.")
                                }
                            )
                            
                            TestingButton(
                                title: "Missed Day",
                                subtitle: "Preserves current streak, resets to 0",
                                color: Color.orange,
                                action: {
                                    TestingService.shared.mockStreakScenario(.missedDay, appModel: appModel)
                                    showAlert(title: "Missed Day Applied", message: "Current streak reset to 0. Highest streak and completed count preserved.")
                                }
                            )
                        }
                        
                        VStack(spacing: 10) {
                            TestingButton(
                                title: "Force Sync to Backend",
                                subtitle: "Sync current streak data",
                                color: globalSettings.primaryLightBlueColor,
                                action: {
                                    Task {
                                        await TestingService.shared.forceSyncStreakData(appModel: appModel)
                                        await MainActor.run {
                                            showAlert(title: "Sync Attempted", message: "Check console for sync results.")
                                        }
                                    }
                                }
                            )
                            
                            TestingButton(
                                title: "Print Streak State",
                                subtitle: "Debug current state",
                                color: globalSettings.primaryGrayColor,
                                action: {
                                    TestingService.shared.printStreakState(appModel: appModel)
                                    showAlert(title: "Streak State", message: "Check console for detailed streak state info.")
                                }
                            )
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Quick Actions Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("⚡ Quick Actions")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundColor(globalSettings.primaryDarkColor)
                        
                        TestingButton(
                            title: "Complete Today's Session",
                            subtitle: "Add full session for today",
                            color: globalSettings.primaryGreenColor,
                            action: {
                                let session = CompletedSession(
                                    date: Date(),
                                    drills: TestingService.shared.createMockDrills(completed: true),
                                    totalCompletedDrills: 3,
                                    totalDrills: 3
                                )
                                appModel.addCompletedSession(
                                    date: Date(),
                                    drills: session.drills,
                                    totalCompletedDrills: 3,
                                    totalDrills: 3
                                )
                                showAlert(title: "Session Added", message: "Today's session has been marked as complete.")
                            }
                        )
                        
                        TestingButton(
                            title: "Toggle Simulation Mode",
                            subtitle: appModel.inSimulationMode ? "Disable simulation" : "Enable simulation",
                            color: globalSettings.primaryYellowColor,
                            action: {
                                appModel.inSimulationMode.toggle()
                                showAlert(title: "Simulation Mode", message: "Simulation mode is now \(appModel.inSimulationMode ? "enabled" : "disabled").")
                            }
                        )
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Testing Tools")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func testTokenRefresh() {
        isTestingTokenRefresh = true
        TestingService.shared.testTokenRefresh { success in
            isTestingTokenRefresh = false
            showAlert(
                title: success ? "Refresh Success" : "Refresh Failed",
                message: success ? "Token refresh flow worked correctly." : "Token refresh failed. Check console for details."
            )
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

// MARK: - Testing Button Component

struct TestingButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    let disabled: Bool
    
    let globalSettings = GlobalSettings.shared
    
    init(title: String, subtitle: String, color: Color, action: @escaping () -> Void, disabled: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.action = action
        self.disabled = disabled
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Poppins-Bold", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Text(subtitle)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(disabled ? color.opacity(0.5) : color)
            .cornerRadius(8)
        }
        .disabled(disabled)
    }
}

// MARK: - Preview

#if DEBUG
struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel()
        let userManager = UserManager()
        
        TestingView(appModel: appModel, sessionModel: sessionModel, userManager: userManager)
    }
}
#endif 
