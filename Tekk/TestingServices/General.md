
# Testing Tools for BravoBall

This directory contains comprehensive testing tools for debugging authentication and streak progression scenarios in the BravoBall Swift app.

## Overview

The testing tools help you verify:
1. **Authentication Flow**: Token refresh, expiration handling, and logout scenarios
2. **Streak Progression**: Accurate streak calculation, reset detection, and database sync

## Setup

### Prerequisites
- Set `AppSettings.debug = true` in `GlobalSettings.swift`
- The testing tab will automatically appear in the main tab bar (🔧 icon)

### Access the Testing Tools
1. Run the app in debug mode
2. Navigate to the "Testing" tab (5th tab with wrench icon)
3. Use the various testing buttons to simulate scenarios

## Authentication Testing

### Available Tests

#### 1. Mock Expired Access Token
- **Purpose**: Test 401 error handling and token refresh flow
- **What it does**: Replaces your access token with an expired one
- **Expected behavior**: Next API call should trigger automatic token refresh

#### 2. Mock Invalid Refresh Token
- **Purpose**: Test logout scenario when refresh fails
- **What it does**: Replaces refresh token with invalid one
- **Expected behavior**: User should be logged out when refresh fails

#### 3. Mock Both Tokens Expired
- **Purpose**: Test complete authentication failure
- **What it does**: Invalidates both access and refresh tokens
- **Expected behavior**: User should be immediately logged out

#### 4. Test Token Refresh
- **Purpose**: Test complete refresh flow with safety restoration
- **What it does**: 
  1. Stores original tokens
  2. Mocks expired access token
  3. Makes API call to trigger refresh
  4. Restores original tokens if refresh fails
- **Expected behavior**: Should successfully refresh tokens or safely restore originals

### How to Test Token Expiration

1. **Test Normal Refresh Flow**:
   ```
   1. Tap "Mock Expired Access Token"
   2. Navigate to another screen that makes API calls
   3. Watch console for refresh attempt
   4. Verify user stays logged in
   ```

2. **Test Logout Scenario**:
   ```
   1. Tap "Mock Invalid Refresh Token"
   2. Tap "Mock Expired Access Token"
   3. Navigate to another screen
   4. Verify user gets logged out
   ```

3. **Test Complete Flow**:
   ```
   1. Tap "Print Auth State" (note current tokens)
   2. Tap "Test Token Refresh"
   3. Check alert result
   4. Tap "Print Auth State" again to verify
   ```

## Streak Testing

### Available Scenarios

#### 1. No Streak
- Resets everything to zero state
- Good for testing initial user experience

#### 2. Active Streak (7 or 30 days)
- Creates consecutive daily sessions
- Tests streak display and progression

#### 3. Broken Streak
- Creates a gap in the streak
- Tests streak reset logic

#### 4. Streak Reset Trigger
- Creates scenario that should show reset message
- Tests the "streak lost" notification

#### 5. Partial Session
- Creates incomplete session for today
- Tests behavior when session isn't 100% complete

### How to Test Streak Progression

1. **Test Streak Calculation**:
   ```
   1. Tap "No Streak" to reset
   2. Tap "7-Day Streak" to create streak
   3. Tap "Print Streak State" to verify
   4. Check that calendar shows correct streak
   ```

2. **Test Streak Reset Message**:
   ```
   1. Tap "Streak Reset Trigger"
   2. Navigate to Progression tab
   3. Verify reset message appears
   ```

3. **Test Database Sync**:
   ```
   1. Create any streak scenario
   2. Tap "Force Sync to Backend"
   3. Check console for sync results
   4. Restart app to verify data persists
   ```

### Testing Streak Accuracy

To verify streak calculation matches database:

1. **Before Testing**:
   - Note your current streak values
   - Tap "Print Streak State" to get baseline

2. **Create Test Scenario**:
   - Use any streak scenario button
   - Tap "Force Sync to Backend"
   - Check console for sync success

3. **Verify Persistence**:
   - Force close and restart app
   - Check if streak values match
   - Compare with database values

## Quick Actions

### Complete Today's Session
- Adds a completed session for today
- Useful for testing daily progression

### Toggle Simulation Mode
- Enables/disables simulation features
- Shows additional testing buttons in calendar

## Console Output

All testing actions provide detailed console output. Key things to watch for:

### Authentication Logs
```
🧪 TESTING: Token refresh test result: SUCCESS
🔑 Access token: abc123...
🔄 Refresh token: def456...
```

### Streak Logs
```
🧪 TESTING: Streak scenario applied successfully
   - Current streak: 7
   - Highest streak: 7
   - Total sessions: 7
   - Completed sessions: 7
```

### API Sync Logs
```
✅ Successfully synced progress history
✅ Successfully synced completed session
```

## Troubleshooting

### Common Issues

1. **Testing Tab Not Showing**:
   - Verify `AppSettings.debug = true`
   - Rebuild and run app

2. **Token Refresh Not Working**:
   - Check network connection
   - Verify backend is running
   - Check console for error messages

3. **Streak Not Syncing**:
   - Ensure valid authentication
   - Check backend connectivity
   - Verify API endpoints are correct

### Debug Console Commands

Print current state anytime:
```swift
// In any view controller or service
TestingService.shared.printAuthenticationState()
TestingService.shared.printStreakState(appModel: appModel)
```

## Best Practices

1. **Always restore original state** after testing
2. **Use "Print State" buttons** to verify before and after
3. **Test with real backend** to verify sync behavior
4. **Check both UI and console** for complete verification
5. **Test edge cases** like partial sessions and broken streaks

## Integration with Existing Tests

The testing tools work alongside existing features:
- Calendar test button (when `inSimulationMode` is enabled)
- Debug flags in `UserManager`
- Existing streak logic in `MainAppModel`

## Notes

- Testing tools are only available in debug builds
- All changes are applied immediately to the app state
- Use responsibly - these tools modify real user data
- Always verify with backend database for accuracy 
