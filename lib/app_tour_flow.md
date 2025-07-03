// Test file to verify the onboarding flow works

/*
How the App Tour Flow Works:

1. When the app starts, Wrapper.dart checks:
   - If user exists in database
   - If user has seen onboarding

2. Flow options:
   - New user (no account) → Welcome screen → Account setup → App tour → Dashboard
   - Existing user (first time after app tour feature) → App tour → Dashboard  
   - Existing user (has seen tour) → Dashboard directly

3. App Tour Features:
   - 6 informative screens explaining app features
   - Beautiful animations and icons
   - Skip and navigation buttons
   - Progress indicators
   - Saves completion status to SharedPreferences

4. Dashboard Tutorial:
   - Interactive tooltips using TutorialCoachMark
   - Points to FAB and bottom navigation
   - Shows after app tour completion
   - Can be skipped or completed

Usage:
- First time users will see the app tour automatically
- Tour completion is saved so it won't show again
- Dashboard tutorial shows interactive elements
- Users can navigate through at their own pace
*/
