# Project Architecture & Structure

## Directory Structure

```
lib/
├── main.dart                           # App entry point, theme, RouteObserver
├── models/                             # Data models
│   ├── isar_models.dart               # Goal & Record Isar collections
│   └── isar_models.g.dart             # Generated Isar code
├── screens/                            # UI screens
│   ├── home_screen.dart               # Goals dashboard
│   ├── goal_detail_screen.dart        # Goal progress & timeline
│   ├── new_goal_screen.dart           # Goal creation form
│   ├── record_screen.dart             # Video recording interface
│   ├── edit_record_screen.dart        # New record editing
│   ├── edit_record_review_screen.dart # Existing record editing
│   └── try_record_detail_screen.dart  # (Placeholder/unused)
├── services/                           # Business logic & external integrations
│   ├── isar_service.dart              # Database operations
│   └── camera_service.dart            # Camera & media management
├── utils/                              # Utilities & constants
│   └── app_colors.dart                # Color system
└── widgets/                            # Reusable UI components
    ├── goal_card.dart                 # Goal display card
    └── bottom_nav_bar.dart            # Navigation bar
```

## Layer Responsibilities

### Models Layer (`lib/models/`)
**Purpose**: Define data structures and relationships

- **Goal Model**: Represents a user's goal with 21-attempt target
  - Fields: id, uuid, title, createdAt
  - Relationship: One-to-many with Record
- **Record Model**: Represents a single attempt at a goal
  - Fields: id, uuid, title, description, assetId, createdAt
  - Relationship: Many-to-one with Goal

**Rules**:
- All models are Isar collections with `@Collection()` annotation
- Use `Id` type for auto-increment local IDs
- Use `String uuid` for stable cross-device identifiers
- Use `IsarLinks<T>` for one-to-many relationships
- Use `IsarLink<T>` for many-to-one relationships
- Include `part` directive for generated code

### Services Layer (`lib/services/`)
**Purpose**: Encapsulate business logic and external integrations

#### IsarService
- **Responsibility**: All database CRUD operations
- **Pattern**: Static methods for global access
- **Initialization**: Must call `initialize()` before use
- **Operations**:
  - Goal CRUD: getAllGoals, getGoalById, saveGoal, deleteGoal
  - Record CRUD: getAllRecords, getRecordById, saveRecord, deleteRecord
  - Relationships: getRecordsByGoalId, saveRecordWithGoal
- **UUID Management**: Automatically generates UUIDs if not present

#### CameraService
- **Responsibility**: Camera control and media management
- **Pattern**: Instance-based service with lifecycle management
- **Operations**:
  - Camera: initializeCameras, initializeCamera, switchCamera
  - Recording: startVideoRecording, stopVideoRecording
  - Photo: takePhoto
  - Gallery: saveVideoToGallery, savePhotoToGallery, getVideoPathFromAssetId
- **State**: Tracks recording state internally
- **Cleanup**: Must call `dispose()` when done

### Screens Layer (`lib/screens/`)
**Purpose**: Full-screen UI components representing app pages

**Screen Naming Convention**: `{feature}_screen.dart`

**Common Patterns**:
- Extend `StatefulWidget` for screens with dynamic data
- Load data in `initState()`
- Use `RouteAware` mixin for automatic refresh on navigation return
- Subscribe to `routeObserver` in `didChangeDependencies()`
- Implement `didPopNext()` to reload data when returning from child routes
- Always dispose resources in `dispose()`

**Screen Structure**:
```dart
class FeatureScreen extends StatefulWidget {
  @override
  State<FeatureScreen> createState() => _FeatureScreenState();
}

class _FeatureScreenState extends State<FeatureScreen> with RouteAware {
  // State variables
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }
  
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  
  @override
  void didPopNext() {
    _loadData(); // Refresh when returning from child route
  }
  
  Future<void> _loadData() async {
    // Load data from services
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildContent()),
      bottomNavigationBar: BottomNavBar(...),
    );
  }
  
  Widget _buildContent() { /* ... */ }
}
```

### Widgets Layer (`lib/widgets/`)
**Purpose**: Reusable UI components used across multiple screens

**Widget Naming Convention**: `{component}_widget.dart` or `{component}.dart`

**Guidelines**:
- Prefer `StatelessWidget` unless internal state is needed
- Accept data via constructor parameters
- Use callbacks for user interactions
- Keep widgets focused on single responsibility

### Utils Layer (`lib/utils/`)
**Purpose**: Constants, helpers, and utility functions

**Current Utilities**:
- **AppColors**: Centralized color constants for design system

**Guidelines**:
- Use static classes for constants
- Use static methods for pure utility functions
- Keep utilities focused and cohesive

## Navigation Architecture

### Navigation Pattern
- **Primary**: Push navigation with MaterialPageRoute
- **Bottom Navigation**: Tab-based navigation for main sections
- **Route Observer**: Global RouteObserver for tracking navigation events

### Navigation Flow
```
HomeScreen (Goals List)
  ├─> GoalDetailScreen (Progress & Timeline)
  │     ├─> RecordScreen (Video Recording)
  │     │     └─> EditRecordScreen (Add Details)
  │     └─> EditRecordReviewScreen (Edit Existing)
  └─> NewGoalScreen (Create Goal)
```

### Route Awareness Pattern
```dart
// In main.dart
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

// In MaterialApp
navigatorObservers: [routeObserver]

// In screens that need refresh on return
class _ScreenState extends State<Screen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }
  
  @override
  void didPopNext() {
    _loadData(); // Refresh when returning
  }
}
```

## Data Flow Architecture

### Data Flow Pattern
1. **Screen** requests data from **Service**
2. **Service** queries **Database** (Isar)
3. **Service** returns **Models** to **Screen**
4. **Screen** updates UI with `setState()`

### Example: Recording a New Attempt
```
RecordScreen
  └─> CameraService.startVideoRecording()
  └─> CameraService.stopVideoRecording() → videoPath
  └─> CameraService.saveVideoToGallery(videoPath) → assetId
  └─> Navigate to EditRecordScreen(assetId)

EditRecordScreen
  └─> User enters title & description
  └─> IsarService.saveRecordWithGoal(record, goalId)
  └─> Navigate back to GoalDetailScreen

GoalDetailScreen
  └─> didPopNext() triggered
  └─> IsarService.getRecordsByGoalId(goalId)
  └─> setState() with updated records
```

## State Management Strategy

### Current Approach: Local State with setState
- **Rationale**: Simple app with limited shared state
- **Pattern**: Each screen manages its own state
- **Refresh Strategy**: Reload from database on screen focus

### When to Use setState
- UI state changes (loading, selected index, etc.)
- Data loaded from services
- User input changes

### When to Reload Data
- `initState()`: Initial load
- `didPopNext()`: Returning from child route
- After navigation with `.then((_) => _loadData())`

## Code Generation

### Isar Code Generation
- **Source**: `lib/models/isar_models.dart`
- **Generated**: `lib/models/isar_models.g.dart`
- **Command**: `flutter pub run build_runner build --delete-conflicting-outputs`
- **When**: After modifying Isar models

### Generated Code Rules
- Never edit `.g.dart` files manually
- Commit generated files to version control
- Run build_runner after pulling model changes

## Error Handling Patterns

### Service Layer
- Use `try-catch` blocks for all async operations
- Log errors with `debugPrint()`
- Return `null` or empty lists on failure
- Throw exceptions for critical failures (e.g., database not initialized)

### UI Layer
- Check for null/empty data before rendering
- Show loading states during async operations
- Display error messages to user when appropriate
- Gracefully handle missing data

## Memory Management

### Camera Resources
- Initialize camera in `initState()`
- Dispose camera controller in `dispose()`
- Stop recording before disposing

### Video Player Resources
- Initialize video controller when needed
- Dispose video controller in `dispose()`
- Handle controller lifecycle in stateful widgets

### Database Resources
- Isar instance is singleton, no disposal needed
- Close transactions properly
- Load relationships explicitly with `.load()`
