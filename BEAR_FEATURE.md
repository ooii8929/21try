# Bear Habit: Distance Mechanism

## Overview

The Bear Distance mechanism adds gamification to the goal tracking experience. A virtual bear "chases" the user, and the distance between them changes based on check-in behavior.

## How It Works

### Distance Rules
- **Initial Distance**: 5 (safe)
- **Check-in Today**: Distance stays at 5 → show "maintain" image
- **Skip a Day**: Distance decreases by 1 → show corresponding distance image
- **Keep Skipping**: Distance continues decreasing daily (minimum = 0)
- **Distance = 0**: Bear caught you! Must check in to reset
- **Next Check-in**: Distance resets to 5

### User Flow

1. **User opens Goal Detail screen**
   - App checks if distance changed since last visit
   - If distance decreased, shows modal with bear image and warning

2. **User taps Quick Check-in button**
   - Creates a check-in record
   - Triggers bear check-in (distance resets to 5)
   - Shows "maintain" modal with encouraging message

3. **User records video**
   - Same as quick check-in
   - Also saves video record

## Implementation

### Files Created

1. **`lib/models/bear_state.dart`**
   - `BearState`: Stores last check-in date and distance
   - `BearEventResult`: Represents bear events (maintain/decrement/idle)

2. **`lib/services/bear_service.dart`**
   - `getState()`: Load current bear state
   - `getCurrentDistance()`: Calculate current distance
   - `doCheckin()`: User checks in, reset distance
   - `onActivate()`: Check if distance changed, return event if needed
   - Uses `shared_preferences` for persistence

3. **`lib/widgets/bear_event_modal.dart`**
   - Modal dialog showing bear event
   - Displays image, title, description, and distance indicator
   - Different messages for maintain/decrement/caught events

4. **`lib/screens/goal_detail_screen.dart`** (updated)
   - Added bear distance card in progress section
   - Shows current distance with visual indicator
   - Checks bear status on screen load and return from child routes
   - Triggers bear check-in when user taps quick check-in

### Dependencies Added

- `shared_preferences: ^2.2.2` - For persisting bear state

### Assets Structure

```
assets/bear/
├── maintain/           # Happy images when user checks in
│   ├── maintain_001.png
│   ├── maintain_002.png
│   └── maintain_003.png
└── distance/           # Warning images when distance decreases
    ├── d5/            # Distance 5 (safe)
    ├── d4/            # Distance 4
    ├── d3/            # Distance 3
    ├── d2/            # Distance 2 (danger)
    ├── d1/            # Distance 1 (very close)
    └── d0/            # Distance 0 (caught!)
```

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Add Bear Images

Add your bear images to the appropriate directories:
- `assets/bear/maintain/` - Add maintain_001.png, maintain_002.png, etc.
- `assets/bear/distance/d5/` through `d0/` - Add distance-specific images

**Image Requirements**:
- Format: PNG (recommended for transparency)
- Size: 800x600px or similar aspect ratio
- Style: Consistent visual theme
- Content: Bear getting progressively closer

### 3. Test the Feature

```bash
flutter run
```

**Testing Scenarios**:

1. **First Check-in**
   - Open goal detail
   - Tap quick check-in button
   - Should show "maintain" modal with distance 5/5

2. **Skip a Day**
   - Change device date to tomorrow (or wait)
   - Open goal detail
   - Should show "decrement" modal with reduced distance

3. **Multiple Skips**
   - Keep advancing date without checking in
   - Distance should decrease to 0
   - Should show "caught" message

4. **Reset**
   - After being caught, check in
   - Distance should reset to 5

## UI Components

### Bear Distance Card

Located in Goal Detail screen, shows:
- Bear emoji 🐻
- Current distance (X/5)
- Status text (safe/danger/caught)
- Visual distance bar (5 segments)
- Color coding:
  - Green (distance > 2): Safe
  - Orange (distance 1-2): Warning
  - Red (distance 0): Caught

### Bear Event Modal

Shows when:
- User checks in (maintain event)
- Distance decreases (decrement event)

Contains:
- Bear image (random from gallery)
- Event title
- Description text
- Distance indicator
- "Got it!" button to dismiss

## Customization

### Change Base Distance

Edit `bear_service.dart`:
```dart
static const int _baseDistance = 5; // Change to desired value
```

### Modify Event Messages

Edit `bear_event_modal.dart`:
```dart
String _getTitle() {
  // Customize titles
}

String _getDescription() {
  // Customize descriptions
}
```

### Adjust Colors

Edit distance color logic in `goal_detail_screen.dart`:
```dart
final distanceColor = _currentDistance > 2
    ? AppColors.primary      // Safe
    : _currentDistance > 0
        ? Colors.orange      // Warning
        : Colors.red;        // Caught
```

## Future Enhancements

Potential improvements:
1. **Animations**: Animate bear moving closer
2. **Sounds**: Add sound effects for events
3. **Achievements**: Unlock badges for maintaining distance
4. **Customization**: Let users choose different animals
5. **Statistics**: Track longest streak, total check-ins
6. **Notifications**: Remind user when distance is low
7. **Multiple Bears**: Different bears for different goals

## Troubleshooting

### Images Not Showing

1. Check that images exist in correct directories
2. Verify `pubspec.yaml` includes asset paths
3. Run `flutter clean` and `flutter pub get`
4. Check image file names match exactly (case-sensitive)

### Distance Not Updating

1. Check SharedPreferences is working
2. Verify date calculations in `bear_service.dart`
3. Check console logs for errors
4. Try resetting: `await BearService.reset()`

### Modal Not Appearing

1. Check `mounted` state before showing dialog
2. Verify event is not null
3. Check navigation stack (modal needs valid context)
4. Look for errors in console

## Technical Notes

### Date Handling

- Uses local device time (not UTC)
- Truncates to date only (ignores time)
- Calculates days difference for distance

### State Persistence

- Stored in SharedPreferences
- Keys: `bear_lastCheckinDate`, `bear_lastShownDistance`
- Cached in memory for performance

### Image Selection

- Random selection from available images
- Avoids repeating same image consecutively
- Falls back to placeholder if image missing

### Performance

- Minimal overhead (single SharedPreferences read)
- No network calls
- Lightweight state management
- Efficient image loading
