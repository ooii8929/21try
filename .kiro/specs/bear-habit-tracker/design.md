# Design Document

## Overview

The Bear Habit Tracker is a gamification layer that encourages consistent user engagement with their goals. It uses a distance-based metaphor where a bear starts 5 units away and approaches the user by 1 unit each day they skip a check-in. Each goal maintains its own independent bear state, and the system provides real-time visual feedback through color-coded indicators, randomized images, and automatic distance updates.

This design leverages the existing 21 Try App architecture by extending the Goal model with bear tracking fields, implementing a BearService for business logic, and integrating real-time updates into the Goal Detail Screen. The implementation includes a test mode (10 seconds = 1 day) for rapid development and testing.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Goal Detail Screen                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Bear Distance Card (4/5 with color indicator)       │  │
│  │  - Real-time updates (every 1 second)                │  │
│  │  - Quick check-in button (✓)                         │  │
│  │  - Reset button (🔄) for testing                     │  │
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
                  ┌──────────────────────┐
                  │  BearService         │
                  │  - getCurrentDistance│
                  │  - doCheckin         │
                  │  - onActivate        │
                  │  - reset             │
                  │  - Test Mode Support │
                  └──────────────────────┘
                            │
                            ▼
                  ┌──────────────────────┐
                  │  Goal Model (Isar)   │
                  │  - lastBearCheckin   │
                  │  - lastBearDistance  │
                  └──────────────────────┘
```

### Integration Points

1. **Goal Model**: Bear state stored directly in Goal Isar collection (lastBearCheckin, lastBearDistance)
2. **Goal Detail Screen**: Primary integration point with real-time distance monitoring via Timer
3. **Record Creation Flow**: Automatic check-in when user creates a new record or uses quick check-in
4. **Screen Lifecycle**: Distance recalculation on screen activation (initState, didPopNext)
5. **Real-time Updates**: Timer.periodic checks distance every 1 second while screen is visible
6. **Test Mode**: Configurable mode where 10 seconds = 1 day for rapid testing

## Components and Interfaces

### 1. Goal Model Extension

**Purpose**: Store bear tracking state directly in the Goal Isar collection.

```dart
@Collection()
class Goal {
  // ... existing fields
  
  // Bear Distance fields
  DateTime? lastBearCheckin;  // Last check-in timestamp (includes time for test mode)
  int lastBearDistance = 5;   // Last recorded distance (default 5)
}
```

**Key Properties**:
- `lastBearCheckin`: DateTime of last check-in (null for new goals, includes time for test mode precision)
- `lastBearDistance`: Last recorded distance value (default 5, decreases as days pass)

**Design Rationale**:
- Stores state directly in Goal model instead of separate SharedPreferences
- Leverages existing Isar persistence layer
- Each goal has independent bear tracking
- No additional persistence layer needed

### 2. BearState Model (Legacy/Compatibility)

**Purpose**: Simple data class for representing bear state (used for JSON serialization in documentation).

```dart
class BearState {
  final DateTime? lastCheckinLocalDate;
  final int baseDistance;
  final int lastShownDistance;
  
  const BearState({
    this.lastCheckinLocalDate,
    this.baseDistance = 5,
    this.lastShownDistance = 5,
  });
  
  // JSON serialization methods
  factory BearState.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  BearState copyWith({...});
}
```

**Note**: This model is primarily used for documentation and testing. Actual state is stored in Goal model.

### 3. BearEventResult Model

**Purpose**: Represents the result of a bear system action (check-in or activation).

```dart
class BearEventResult {
  final String eventType;      // "maintain", "decrement", or "idle"
  final int distanceAfter;     // Distance after the event
  final String? imageAssetPath; // Path to bear image
  final int? previousDistance;  // Previous distance (for decrement events)
  
  const BearEventResult({
    required this.eventType,
    required this.distanceAfter,
    this.imageAssetPath,
    this.previousDistance,
  });
}
```

**Event Types**:
- `"maintain"`: User checked in, distance maintained at current value
- `"decrement"`: Distance decreased due to time passing
- `"idle"`: No change (not typically returned, represented by null)

### 4. BearService

**Purpose**: Core business logic for bear tracking system. Handles distance calculation, event detection, and state management with test mode support.

```dart
class BearService {
  static const int _baseDistance = 5;
  static const bool _testMode = true;  // Toggle for test mode
  static const int _testIntervalSeconds = 10;  // 10 seconds = 1 day in test mode
  
  // Get current distance for a goal
  static Future<int> getCurrentDistance(int goalId);
  
  // User performs check-in (maintains current distance)
  static Future<BearEventResult> doCheckin(int goalId);
  
  // Called when screen activates to detect distance changes
  static Future<BearEventResult?> onActivate(int goalId);
  
  // Reset bear state for a goal (testing/development)
  static Future<void> reset(int goalId);
  
  // Private: Calculate days gap (supports test mode)
  static int _calculateDaysGap(DateTime lastCheckin, DateTime now);
  
  // Private: Select random image from gallery
  static String? _selectRandomImage(String type, {int? distance});
  
  // Private: Get local date only (truncate time)
  static DateTime _localDateOnly(DateTime dateTime);
}
```

**Key Methods**:

- `getCurrentDistance(goalId)`: Calculates and returns current distance based on time since last check-in
- `doCheckin(goalId)`: Maintains current distance (doesn't reset to 5), updates Goal model, returns maintain event
- `onActivate(goalId)`: Detects if distance decreased since last check, updates Goal model if changed
- `reset(goalId)`: Resets Goal's bear state to initial values (lastBearCheckin=null, lastBearDistance=5)
- `_calculateDaysGap(...)`: Calculates days passed (or simulated days in test mode)

**Test Mode Behavior**:
- When `_testMode = true`: 10 seconds = 1 day
- When `_testMode = false`: Uses real calendar days
- Logs simulated day calculations for debugging

### 5. Image Asset Management

**Purpose**: Bear images are managed directly within BearService using hardcoded asset paths.

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
        d3_002.png
      d2/
        d2_001.png
        d2_002.png
      d1/
        d1_001.png
        d1_002.png
      d0/
        d0_001.png
        d0_002.png
```

**Image Selection Logic**:
- `_selectRandomImage(type, distance)` method in BearService
- Randomly selects from available images for the event type/distance
- Avoids repeating the last shown image when possible
- Returns null if no images available (graceful degradation)

## Data Models

### Goal Model Schema (Bear Fields)

Bear state is stored directly in the Goal Isar collection:

```dart
@Collection()
class Goal {
  Id id = Isar.autoIncrement;
  late String uuid;
  late String title;
  late DateTime createdAt;
  
  // Bear Distance fields
  DateTime? lastBearCheckin;  // Null for new goals, DateTime with time for test mode
  int lastBearDistance = 5;   // Default 5, decreases as days pass
  
  // Relationships
  final records = IsarLinks<Record>();
}
```

### Date Handling

**Production Mode**: Dates are truncated to day precision for comparison

```dart
DateTime _localDateOnly(DateTime dt) {
  return DateTime(dt.year, dt.month, dt.day);
}

// Usage in production mode
final today = _localDateOnly(DateTime.now());
final lastDate = _localDateOnly(lastBearCheckin!);
final daysGap = today.difference(lastDate).inDays;
```

**Test Mode**: Full DateTime with seconds precision for rapid testing

```dart
// Usage in test mode (10 seconds = 1 day)
final secondsGap = now.difference(lastBearCheckin!).inSeconds;
final simulatedDays = secondsGap ~/ 10;  // Integer division
```

## Error Handling

### Missing Image Assets

**Scenario**: Image gallery directory is empty or missing

**Handling**:
- `_selectRandomImage()` returns `null` if no images found
- UI displays event modal without image, showing only text message
- Log warning with `debugPrint` for debugging
- Graceful degradation - feature still works without images

### Goal Not Found

**Scenario**: Attempting to access bear state for non-existent goal

**Handling**:
- `BearService.getCurrentDistance()` returns base distance (5) if goal is null
- `BearService.doCheckin()` throws exception if goal is null
- `BearService.onActivate()` returns null if goal is null
- Log error with `debugPrint`
- Caller (UI) should ensure valid goal before calling

### Null Check-in History

**Scenario**: Goal has never been checked in (lastBearCheckin is null)

**Handling**:
- `getCurrentDistance()` returns base distance (5)
- `onActivate()` returns null (no event)
- First check-in initializes lastBearCheckin
- No special error handling needed

### Timer Lifecycle

**Scenario**: Screen disposed while timer is running

**Handling**:
- Timer is cancelled in `dispose()` method
- Check `mounted` before calling `setState()`
- Prevents memory leaks and errors
- Standard Flutter lifecycle management

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

1. **Bear Distance Card** (above progress section):
```dart
Widget _buildBearDistanceCard() {
  final distanceColor = _currentDistance > 2
      ? AppColors.primary      // Green for safe (3-5)
      : _currentDistance > 0
          ? Colors.orange      // Orange for warning (1-2)
          : Colors.red;        // Red for caught (0)
  
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('🐻', style: TextStyle(fontSize: 24)),
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
            Row(
              children: [
                // Quick check-in button
                GestureDetector(
                  onTap: _handleQuickCheckin,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: 8),
                // Reset button (for testing)
                GestureDetector(
                  onTap: _handleReset,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.refresh, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        // Distance indicator
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index < _currentDistance
                            ? distanceColor
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(width: 12),
            Text(
              '$_currentDistance/5',
              style: TextStyle(
                color: distanceColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          _getBearStatusText(),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
```

2. **Bear Event Modal** (using BearEventModal widget):
```dart
void _showBearEventModal(BearEventResult event) {
  if (!mounted) return;
  
  showDialog(
    context: context,
    builder: (context) => BearEventModal(event: event),
  );
}
```

**Lifecycle Integration with Real-time Updates**:

```dart
class _GoalDetailScreenState extends State<GoalDetailScreen> with RouteAware {
  int _currentDistance = 5;
  Timer? _distanceUpdateTimer;
  
  @override
  void initState() {
    super.initState();
    _loadRecords();
    _initializeBearSystem();
    _startDistanceUpdateTimer();  // Start real-time monitoring
  }
  
  @override
  void dispose() {
    _distanceUpdateTimer?.cancel();  // Clean up timer
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  
  Future<void> _initializeBearSystem() async {
    // Load current distance
    final distance = await BearService.getCurrentDistance(widget.goal.id);
    if (mounted) {
      setState(() {
        _currentDistance = distance;
      });
    }
    
    // Check for distance changes since last visit
    final event = await BearService.onActivate(widget.goal.id);
    if (event != null) {
      _showBearEventModal(event);
      if (mounted) {
        setState(() {
          _currentDistance = event.distanceAfter;
        });
      }
    }
  }
  
  void _startDistanceUpdateTimer() {
    // Check distance every 1 second for real-time updates
    _distanceUpdateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        final newDistance = await BearService.getCurrentDistance(widget.goal.id);
        if (mounted && newDistance != _currentDistance) {
          setState(() {
            _currentDistance = newDistance;
          });
        }
      },
    );
  }
  
  @override
  void didPopNext() {
    _loadRecords();
    _initializeBearSystem(); // Re-check on return from child route
  }
  
  Future<void> _handleQuickCheckin() async {
    // Quick check-in button handler
    final event = await BearService.doCheckin(widget.goal.id);
    if (mounted) {
      setState(() {
        _currentDistance = event.distanceAfter;
      });
      _showBearEventModal(event);
    }
  }
  
  Future<void> _handleReset() async {
    // Reset button handler (for testing)
    await BearService.reset(widget.goal.id);
    if (mounted) {
      setState(() {
        _currentDistance = 5;
      });
    }
  }
  
  Future<void> _onRecordCreated() async {
    // Trigger check-in when record is created
    final event = await BearService.doCheckin(widget.goal.id);
    if (mounted) {
      setState(() {
        _currentDistance = event.distanceAfter;
      });
      _showBearEventModal(event);
    }
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

### Why Store in Goal Model Instead of SharedPreferences?

**Decision**: Store bear state directly in Goal Isar collection instead of SharedPreferences

**Rationale**:
- Leverages existing persistence layer (Isar)
- Maintains data consistency with Goal lifecycle
- Simpler architecture - no separate persistence service needed
- Automatic cleanup when Goal is deleted
- Better for future cloud sync (all Goal data in one place)
- Type-safe with Isar's schema validation

### Why Per-Goal Bear State?

**Decision**: Each goal has its own independent bear tracking

**Rationale**:
- Aligns with app's goal-centric design
- Users can focus on different goals at different times
- More granular feedback and motivation
- Simpler logic than global bear state

### Why Store Full DateTime Instead of Date-Only?

**Decision**: Store full DateTime (with time) instead of date-only

**Rationale**:
- Enables test mode with second-precision (10 seconds = 1 day)
- Production mode truncates to date-only for comparison
- More flexible for future features (time-based challenges)
- Simpler implementation - no need for date conversion on storage
- Test mode requires precise timestamps for rapid testing

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

### Why Maintain Distance Instead of Reset to 5?

**Decision**: Check-in maintains current distance rather than resetting to 5

**Rationale**:
- More challenging and engaging gameplay
- Creates tension and urgency
- Encourages consistent daily check-ins
- Once distance decreases, it's harder to recover
- More realistic "maintaining distance" metaphor
- Prevents gaming the system by checking in only when caught

### Why Real-time Updates with Timer?

**Decision**: Use Timer.periodic to check distance every 1 second

**Rationale**:
- Immediate visual feedback in test mode (10 seconds = 1 day)
- Users see distance decrease in real-time without navigation
- Better user experience - no need to leave and return
- Minimal performance impact (simple calculation)
- Easy to implement with Flutter's Timer API
- Automatically stops when screen is disposed
