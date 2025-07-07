
# Quick Testing Guide

## 🚀 Getting Started (2 minutes)

1. **Enable Debug Mode**: Ensure `AppSettings.debug = true` in `GlobalSettings.swift`
2. **Find Testing Tab**: Look for 🔧 icon in bottom tab bar (5th tab)
3. **Open Xcode Console**: View → Debug Area → Activate Console to see logs

## 🔐 Test Authentication Issues

### Quick Test: "Are users being logged out too fast?"

**Scenario 1: Normal token refresh (should work)**
```
1. Tap "Mock Expired Access Token"
2. Go to Home tab and scroll around
3. ✅ User should stay logged in
4. Check console for "Token refresh test result: SUCCESS"
```

**Scenario 2: Complete auth failure (should log out)**
```
1. Tap "Mock Both Tokens Expired"  
2. Go to Home tab and scroll around
3. ✅ User should be logged out
4. Check console for auth errors
```

**Scenario 3: Test full refresh flow**
```
1. Tap "Test Token Refresh" button
2. Wait for alert result
3. ✅ Should say "Refresh Success"
4. If fails, check your network/backend
```

## 🔥 Test Streak Progression

### Quick Test: "Is streak calculation accurate?"

**Test 1: Create and verify streak**
```
1. Tap "Print Streak State" (note current values)
2. Tap "7-Day Streak"
3. Tap "Print Streak State" (should show 7 days)
4. Go to Progression tab - verify calendar shows streak
5. Tap "Force Sync to Backend"
6. ✅ Check console for "Successfully synced progress history"
```

**Test 2: Test streak reset message**
```
1. Tap "Streak Reset Trigger"
2. Go to Progression tab
3. ✅ Should see streak reset popup
```

**Test 3: Verify database sync**
```
1. Create any streak scenario
2. Tap "Force Sync to Backend"
3. Force close app completely
4. Reopen app
5. ✅ Streak should match what you set
```

## 🧪 Console Output to Watch For

### ✅ Good Signs:
```
✅ Successfully synced progress history
✅ Token refresh test result: SUCCESS
🔄 Access token expired, attempting refresh...
✅ Successfully synced completed session
```

### ❌ Bad Signs:
```
❌ Token refresh test result: FAILED
❌ Failed to sync streak data
❌ Network error. Please try again.
❌ Invalid or expired token
```

## 📱 Real-World Testing

### Test "User logged out too fast" complaint:
1. Use your real production tokens (don't mock anything)
2. Use app normally for 10-15 minutes
3. If you get logged out unexpectedly:
   - Check console for token refresh attempts
   - Look for 401 errors
   - Note if refresh token also expired

### Test "Streak not accurate" complaint:
1. Complete a real session today
2. Check streak in app vs database
3. Use "Print Streak State" to see calculated values
4. Compare with backend `/api/progress_history/` response

## 🔧 Emergency Commands

**If something breaks during testing:**
```swift
// Reset to clean state
TestingService.shared.mockStreakScenario(.noStreak, appModel: appModel)

// Check what's in keychain
TestingService.shared.printAuthenticationState()

// See current app state
TestingService.shared.printStreakState(appModel: appModel)
```

## 📋 Quick Checklist

Before reporting "fixed" or "broken":

**Authentication:**
- [ ] Token refresh works with expired access token
- [ ] User gets logged out with invalid refresh token  
- [ ] No unexpected logouts during normal usage
- [ ] Console shows proper refresh attempts

**Streak Progression:**  
- [ ] Streak calculates correctly in UI
- [ ] Streak syncs to backend successfully
- [ ] Streak persists after app restart
- [ ] Reset message shows when appropriate
- [ ] Calendar displays match internal state

## 💡 Pro Tips

1. **Always check console** - most issues show up there first
2. **Test with real backend** - localhost might behave differently  
3. **Use "Print State" buttons** before and after tests
4. **Test edge cases** - partial sessions, broken streaks, etc.
5. **Verify both ways** - app state AND database state

---
*Need help? Check the full README.md for detailed explanations.* 
