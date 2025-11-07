# Onboarding Screen Guide

## Overview
The onboarding screen introduces new users to the bear feature and the 21-day journey concept.

## Implementation

### Screen: `lib/screens/onboarding_screen.dart`
- 4-page swipeable introduction
- Page indicator dots
- Next/Get Started button
- Uses intro images from `assets/bear/intro/`

### Pages Content
1. **Add Your Life Goals** - Journey begins
2. **Beware of the Dream Bear** - Bear chases if you slack
3. **Don't Let the Bear Catch You** - 5-day warning
4. **Escape the Bear's Grasp** - 21-day persistence goal

### Persistence
- Uses `shared_preferences` to track if user has seen onboarding
- Key: `hasSeenOnboarding` (boolean)
- Checked in `main.dart` on app startup
- Set to `true` when user completes onboarding

### Navigation Flow
```
App Launch
  ├─> First Time: OnboardingScreen → HomeScreen
  └─> Returning: HomeScreen (directly)
```

## Testing
To test onboarding again:
1. Clear app data/reinstall app, OR
2. Manually clear SharedPreferences in code

## Assets Used
- `assets/bear/intro/1-start.png`
- `assets/bear/intro/2-run.png`
- `assets/bear/intro/3-end.png`
- `assets/bear/intro/4-done.png`
