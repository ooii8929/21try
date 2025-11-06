# Design Document

## Overview

The Bear Habit Tracker is a gamification layer that encourages consistent user engagement with their goals. It uses a distance-based metaphor where a bear starts 5 units away and approaches the user by 1 unit each day they skip a check-in. The system provides visual feedback through randomized images and integrates seamlessly into the existing Goal Detail Screen.

This design leverages the existing 21 Try App architecture, adding a new state management layer for bear tracking, a service for bear logic, and UI components for visual feedback.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Goal Detail Screen                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Bear Distance Display (Distance: 4/5)               │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Progress Section (21 Try Progress)                  │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Timeline Section (Records)                          │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Record Try Button (triggers check-in)               │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
                  ┌──────────────────┐
                  │  BearService     │
                  │  - doCheckin()   │
                  │  - onActivate()  │
                  │  - getDistance() │
                  └──────────────────┘
                            │
                ┌───────────┴───────────┐
                ▼                       ▼
    ┌──────────────────┐    ┌──────────────────┐
    │ BearStateService │    │ ImageGallery     │
    │ (SharedPrefs)    │    │ Service          │
    └──────────────────┘    └──────────────────┘
```

### Integration Points

1. **Goal Detail Screen**: Primary integration point where bear distance is displayed and check-ins are triggered
2. **Record Creation Flow**: Automatic check-in when user creates a new record
3. **App Lifecycle**: Distance recalculation when app resumes or screen becomes visible
4. **Persistent Storage**: SharedPreferences for storing bear state per goal

## Components and Interfaces

### 1. BearState Model

**Purpose**: Immutable data class representing the current state of the bear tracking system for a specific goal.

```dart
class BearState {
  final DateTime? lastCheckinLocalDate;
  final int baseDistance;
  final int lastShownDistance;
  final String? lastShownImagePath;
  
  const BearState({
    this.lastCheckinLocalDate,
    this.baseDistance = 5,
    this.lastShownDistance = 5,
    this.lastShownImagePath,
  });
  
  // Factory constructor for JSON deserialization
  factory BearState.fromJson(Map<String, dynamic> json);
  
  // Method for JSON serialization
  Map<String, dynamic> toJson();
  
  // Copy with method for immutable updates
  BearState copyWith({...});
}
```

**Key Properties**:
- `lastCheckinLocalDate`: Last date user checked in (date only, no time)
- `baseDistance`: Always 5, represents maximum safe distance
- `lastShownDistance`: Previous distance value to detect decrements
- `lastShownImagePath`: Path to last shown image to avoid repetition

### 2. BearEvent Model

**Purpose**: Represents the result of a bear system action (check-in or activation).

```dart
class BearEvent {
  final BearEventType eventType;
  final int distanceAfter;
  final String? imageAssetPath;
  final String message;
  
  const BearEvent({
    required this.eventType,
    required this.distanceAfter,
    this.imageAssetPath,
    required this.message,
  });
}

enum BearEventType {
  maintain,   // User checked in today
  decrement,  // Distance decreased
  idle,       // No change
}
```

### 3. BearService

**Purpose**: Core business logic for bear tracking system. Handles distance calculation, event detection, and state management.

```dart
class BearService {
  static const String _keyPrefix = 'bear_state_goal_';
  
  // Get current distance for a goal
  static Future<int> getCurrentDistance(int goalId);
  
  // User performs check-in
  static Future<BearEvent> doCheckin(int goalId);
  
  // Called when screen activates to detect distance changes
  static Future<BearEvent?> onActivate(int goalId);
  
  // Private: Load state from SharedPreferences
  static Future<BearState> _loadState(int goalId);
  
  // Private: Save state to SharedPreferences
  static Future<void> _saveState(int goalId, BearState state);
  
  // Private: Calculate computed distance
  static int _calculateDistance(BearState state);
  
  // Private: Detect event type
  static BearEventType _detectEventType(
    BearState state,
    int computedDistance,
    bool isCheckin,
  );
  
  // Private: Generate event message
  static String _generateMessage(BearEventType type, int distance);
}
```

**Key Methods**:

- `getCurrentDistance(goalId)`: Returns current computed distance for display
- `doCheckin(goalId)`: Processes user check-in, resets distance to 5, returns maintain event
- `onActivate(goalId)`: Checks for distance changes since last shown, returns event if changed
- `_calculateDistance(state)`: Computes max(0, baseDistance - daysSinceLastCheckin)
- `_detectEventType(...)`: Determines if event is maintain, decrement, or idle

### 4. ImageGalleryService

**Purpose**: Manages image selection from asset galleries based on event type and distance.

```dart
class ImageGalleryService {
  static const String _basePath = 'assets/bear';
  
  // Get random image for maintain event
  static String? getMaintainImage(String? lastShownPath);
  
  // Get random image for specific distance level
  static String? getDistanceImage(int distance, String? lastShownPath);
  
  // Private: Get all images in a directory
  static List<String> _getImagesInDirectory(String path);
  
  // Private: Select random image avoiding last shown
  static String? _selectRandomImage(
    List<String> images,
    String? lastShownPath,
  );
}
```

**Asset Structure**:
```
assets/
  bear/
    maintain/
      maintain_001.png
      maintain_002.png
      maintain_003.png
    distance/
      d5/
        d5_001.png
      d4/
        d4_001.png
        d4_002.png
      d3/
        d3_001.png
      d2/
        d2_001.png
      d1/
        d1_001.png
      d0/
        d0_001.png
        d0_002.png
```

### 5. BearStateService

**Purpose**: Handles persistence of bear state using SharedPreferences.

```dart
class BearStateService {
  static const String _keyPrefix = 'bear_state_goal_';
  
  // Load bear state for a goal
  static Future<BearState> loadState(int goalId);
  
  // Save bear state for a goal
  static Future<void> saveState(int goalId, BearState state);
  
  // Clear bear state for a goal (for testing/reset)
  static Future<void> clearState(int goalId);
  
  // Private: Get SharedPreferences key for goal
  static String _getKey(int goalId);
}
```

**Storage Format**:
- Key: `bear_state_goal_{goalId}`
- Value: JSON string of BearState
- Example: `{"lastCheckinLocalDate":"2025-11-06","baseDistance":5,"lastShownDistance":4,"lastShownImagePath":"assets/bear/distance/d4/d4_001.png"}`

## Data Models

### BearState Schema

```dart
{
  "lastCheckinLocalDate": "2025-11-06",  // ISO date string (date only)
  "baseDistance": 5,                      // Always 5
  "lastShownDistance": 4,                 // Previous distance value
  "lastShownImagePath": "assets/bear/distance/d4/d4_001.png"  // Last shown image
}
```

### Date Handling

All dates are stored and compared as local dates (truncated to day precision):

```dart
DateTime localDateOnly(DateTime dt) {
  return DateTime(dt.year, dt.month, dt.day);
}

// Usage
final today = localDateOnly(DateTime.now());
final lastCheckin = localDateOnly(state.lastCheckinLocalDate!);
final daysSince = today.difference(lastCheckin).inDays;
```

## Error Handling

### Missing Image Assets

**Scenario**: Image gallery directory is empty or missing

**Handling**:
- `ImageGalleryService` returns `null` if no images found
- UI displays event modal without image, showing only text message
- Log warning with `debugPrint` for debugging

### SharedPreferences Failure

**Scenario**: Unable to read/write to SharedPreferences

**Handling**:
- Catch exception in `BearStateService`
- Return default `BearState` on load failure
- Log error with `debugPrint`
- Continue with in-memory state (won't persist)

### Invalid Date Data

**Scenario**: Corrupted date string in SharedPreferences

**Handling**:
- Catch `FormatException` when parsing date
- Treat as if no previous check-in exists (null date)
- Reset to default state
- Log warning

### Goal Not Found

**Scenario**: Attempting to access bear state for non-existent goal

**Handling**:
- Service methods accept `goalId` but don't validate existence
- Rely on caller (UI) to ensure valid goal
- If goal is deleted, orphaned bear state remains but is harmless

## Testing Strategy

### Unit Tests

**BearService Tests**:
- Test distance calculation with various day gaps
- Test check-in resets distance to 5
- Test event type detection (maintain, decrement, idle)
- Test message generation for each event type
- Test state persistence and retrieval

**ImageGalleryService Tests**:
- Test image selection from maintain gallery
- Test image selection from distance galleries (d0-d5)
- Test avoiding last shown image
- Test handling of empty galleries
- Test handling of single-image galleries

**BearStateService Tests**:
- Test saving and loading state
- Test JSON serialization/deserialization
- Test handling of missing data
- Test handling of corrupted data

### Widget Tests

**Bear Distance Display**:
- Test distance display format "Distance: X/5"
- Test visibility of bear section
- Test styling and layout

**Bear Event Modal**:
- Test modal appears on maintain event
- Test modal appears on decrement event
- Test modal does not appear on idle event
- Test image display in modal
- Test message display in modal
- Test dismiss functionality

### Integration Tests

**Check-in Flow**:
1. User views goal detail screen
2. User taps "Record Try" button
3. User records video and saves
4. System triggers check-in
5. Maintain event modal appears
6. Distance resets to 5

**Distance Decrement Flow**:
1. User checks in on Day 1
2. User closes app
3. User opens app on Day 3 (2 days later)
4. System detects distance decreased to 3
5. Decrement event modal appears
6. Distance display shows 3/5

**Bear Caught Flow**:
1. User checks in on Day 1
2. User doesn't open app for 5+ days
3. User opens app on Day 7
4. System shows distance 0 (bear caught)
5. Special message displayed
6. User checks in to reset

## UI Integration

### Goal Detail Screen Modifications

**New UI Elements**:

1. **Bear Distance Display** (above progress section):
```dart
Widget _buildBearDistanceSection() {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.pets, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text(
              'Bear Distance',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          '$_currentDistance / 5',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
```

2. **Bear Event Modal**:
```dart
void _showBearEventModal(BearEvent event) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event.imageAssetPath != null)
              Image.asset(
                event.imageAssetPath!,
                height: 200,
                fit: BoxFit.contain,
              ),
            SizedBox(height: 16),
            Text(
              event.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Got it'),
            ),
          ],
        ),
      ),
    ),
  );
}
```

**Lifecycle Integration**:

```dart
class _GoalDetailScreenState extends State<GoalDetailScreen> with RouteAware {
  int _currentDistance = 5;
  
  @override
  void initState() {
    super.initState();
    _loadRecords();
    _initializeBearSystem();
  }
  
  Future<void> _initializeBearSystem() async {
    // Load current distance
    final distance = await BearService.getCurrentDistance(widget.goal.id);
    setState(() {
      _currentDistance = distance;
    });
    
    // Check for distance changes
    final event = await BearService.onActivate(widget.goal.id);
    if (event != null && event.eventType != BearEventType.idle) {
      _showBearEventModal(event);
    }
  }
  
  @override
  void didPopNext() {
    _loadRecords();
    _initializeBearSystem(); // Re-check on return
  }
  
  Future<void> _onRecordCreated() async {
    // Trigger check-in when record is created
    final event = await BearService.doCheckin(widget.goal.id);
    setState(() {
      _currentDistance = event.distanceAfter;
    });
    _showBearEventModal(event);
  }
}
```

**Record Button Integration**:

When user completes recording and saves a new record, automatically trigger check-in:

```dart
Widget _buildRecordButton() {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordScreen(goalId: widget.goal.id),
          ),
        );
        
        if (result == true) {
          // Record was created successfully
          await _onRecordCreated();
        }
        
        _loadRecords();
      },
      child: Container(
        // ... existing button UI
      ),
    ),
  );
}
```

## Performance Considerations

### Lazy Loading

- Bear state is loaded only when Goal Detail Screen is opened
- Images are loaded on-demand when events occur
- No background processing or timers

### Memory Management

- BearState is lightweight (< 1KB per goal)
- Images are loaded via Flutter's asset system (cached automatically)
- No in-memory caching needed beyond Flutter's default

### Storage Efficiency

- One SharedPreferences entry per goal
- JSON format is compact and human-readable
- No database schema changes required

### Scalability

- System scales linearly with number of goals
- No cross-goal dependencies
- Each goal's bear state is independent

## Future Enhancements

### Phase 2 Considerations

1. **Customizable Bear Characters**: Allow users to choose different animal mascots
2. **Achievement System**: Unlock special images for maintaining streaks
3. **Notifications**: Remind users when bear is getting close (distance ≤ 2)
4. **Statistics**: Track longest streak, total check-ins, etc.
5. **Social Features**: Share bear images or compete with friends
6. **Animation**: Animate bear movement when distance changes
7. **Sound Effects**: Audio feedback for events

### Migration Path

If moving to cloud sync in the future:
- Add `uuid` field to BearState for cross-device identification
- Sync bear state alongside goal data
- Resolve conflicts by taking most recent check-in date
- Maintain backward compatibility with local-only storage

## Design Decisions

### Why SharedPreferences over Isar?

**Decision**: Use SharedPreferences for bear state instead of adding to Isar database

**Rationale**:
- Bear state is simple key-value data (no relationships)
- Avoids modifying existing Isar schema and regenerating code
- SharedPreferences is sufficient for this use case
- Easier to implement and test
- Can migrate to Isar later if needed

### Why Per-Goal Bear State?

**Decision**: Each goal has its own independent bear tracking

**Rationale**:
- Aligns with app's goal-centric design
- Users can focus on different goals at different times
- More granular feedback and motivation
- Simpler logic than global bear state

### Why Date-Only Comparison?

**Decision**: Store and compare dates without time component

**Rationale**:
- Simplifies logic (no timezone issues)
- Matches user mental model ("I checked in today")
- Prevents multiple check-ins per day from gaming the system
- Consistent with "daily" habit tracking paradigm

### Why Random Image Selection?

**Decision**: Show random images from galleries instead of sequential

**Rationale**:
- Increases variety and surprise
- Prevents predictability
- More engaging user experience
- Simple to implement with avoid-last-shown logic

### Why Modal for Events?

**Decision**: Show events in modal dialog instead of inline

**Rationale**:
- Draws attention to important feedback
- Celebrates user action (check-in)
- Provides clear visual reward
- Doesn't clutter main screen
- Easy to dismiss and continue
