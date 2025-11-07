# 🐻 Bear Distance Feature - Quick Start

## What is This?

A gamification feature that adds a "bear chasing you" mechanic to make goal tracking more engaging and fun!

## How It Works (User Perspective)

1. **🟢 Safe Zone (Distance 5)**: You start safe, bear is far away
2. **📅 Daily Check-in**: Tap the ✓ button or record a video to maintain distance
3. **⚠️ Skip a Day**: Bear moves 1 step closer (distance decreases)
4. **🔴 Bear Catches You (Distance 0)**: Missed too many days!
5. **🔄 Reset**: Check in again to reset distance to 5

## Quick Setup (3 Steps)

### 1. Install Dependencies ✅ (Already Done)

```bash
flutter pub get
```

### 2. Add Bear Images (Optional)

Create or download bear images and add them to:

```
assets/bear/maintain/
  - maintain_001.png
  - maintain_002.png
  - maintain_003.png

assets/bear/distance/d4/
  - d4_001.png
  - d4_002.png

assets/bear/distance/d3/
  - d3_001.png
  - d3_002.png

... (d2, d1, d0 similar)
```

**Note**: Feature works without images (shows placeholder icon)

### 3. Run the App

```bash
flutter run
```

## Where to See It

1. Open any goal from the home screen
2. Look for the **Bear Distance Card** at the top
3. Tap the **✓ Quick Check-in** button to test

## Testing Without Waiting

To test the distance decrease without waiting 24 hours:

1. Check in once (distance = 5)
2. Close the app
3. Change device date to tomorrow
4. Open app → Goal Detail
5. You'll see the "Bear is getting closer!" modal

## User Experience Flow

```
Day 1: Check in → 🎉 "Great Job!" → Distance stays at 5
Day 2: Skip → ⚠️ "Bear is getting closer!" → Distance drops to 4
Day 3: Skip → ⚠️ Distance drops to 3
Day 4: Skip → ⚠️ Distance drops to 2 (orange warning)
Day 5: Skip → 🔴 Distance drops to 1 (red danger)
Day 6: Skip → 🐻 "Bear caught you!" → Distance = 0
Day 7: Check in → 🎉 Distance resets to 5
```

## Visual Indicators

### Bear Distance Card Colors

- **🟢 Green (5-3)**: Safe, keep it up!
- **🟠 Orange (2-1)**: Warning, check in soon!
- **🔴 Red (0)**: Caught! Check in to reset

### Status Messages

- Distance 5: "Safe! Keep checking in daily"
- Distance 4-3: "Getting closer... Check in soon!"
- Distance 2-1: "Danger! Bear is very close!"
- Distance 0: "Bear caught you! Check in to reset"

## Customization

### Change Messages

Edit `lib/widgets/bear_event_modal.dart`:
- `_getTitle()` - Modal titles
- `_getDescription()` - Modal descriptions

Edit `lib/screens/goal_detail_screen.dart`:
- `_getBearStatusText()` - Card status messages

### Change Colors

Edit `lib/screens/goal_detail_screen.dart`:
```dart
final distanceColor = _currentDistance > 2
    ? AppColors.primary      // Change safe color
    : _currentDistance > 0
        ? Colors.orange      // Change warning color
        : Colors.red;        // Change danger color
```

### Change Base Distance

Edit `lib/services/bear_service.dart`:
```dart
static const int _baseDistance = 5; // Change to 7, 10, etc.
```

## Troubleshooting

### "Images not showing"
- Images are optional - placeholder shows if missing
- Add images to `assets/bear/` directories
- Run `flutter clean && flutter pub get`

### "Distance not updating"
- Check console logs for errors
- Verify SharedPreferences is working
- Try resetting: Add debug button with `BearService.reset()`

### "Modal appears multiple times"
- This is a bug - check if `onActivate()` is called multiple times
- Ensure proper state management

## Files to Know

- **`lib/services/bear_service.dart`** - Core logic
- **`lib/widgets/bear_event_modal.dart`** - Modal UI
- **`lib/screens/goal_detail_screen.dart`** - Integration
- **`lib/models/bear_state.dart`** - Data models

## Advanced Features (Future)

Ideas for enhancement:
- 🔔 Push notifications when distance is low
- 📊 Statistics (longest streak, total check-ins)
- 🏆 Achievements and badges
- 🎨 Different animals to choose from
- 🎵 Sound effects
- ✨ Animations

## Support

For detailed documentation:
- **`BEAR_FEATURE.md`** - Complete feature docs
- **`TESTING_BEAR_FEATURE.md`** - Testing guide
- **`IMPLEMENTATION_SUMMARY.md`** - Technical details

## Quick Demo Script

1. Open app → Go to any goal
2. See bear distance card (5/5, green)
3. Tap ✓ quick check-in
4. Modal appears: "Great Job!"
5. Dismiss modal
6. Change device date to tomorrow
7. Open goal again
8. Modal appears: "Bear is getting closer!"
9. See distance is now 4/5 (orange)

That's it! The feature is ready to use. 🎉
