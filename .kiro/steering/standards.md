# Coding Standards & Conventions

## Dart/Flutter Conventions

### File Naming
- **Screens**: `{feature}_screen.dart` (e.g., `home_screen.dart`)
- **Widgets**: `{component}.dart` or `{component}_widget.dart` (e.g., `goal_card.dart`)
- **Services**: `{domain}_service.dart` (e.g., `isar_service.dart`)
- **Models**: `{domain}_models.dart` (e.g., `isar_models.dart`)
- **Utils**: `{purpose}.dart` (e.g., `app_colors.dart`)

### Class Naming
- **Classes**: PascalCase (e.g., `GoalDetailScreen`, `IsarService`)
- **Private Classes**: Prefix with underscore (e.g., `_HomeScreenState`)
- **Widgets**: Descriptive noun (e.g., `GoalCard`, `BottomNavBar`)

### Variable Naming
- **Variables**: camelCase (e.g., `currentIndex`, `videoPath`)
- **Private Variables**: Prefix with underscore (e.g., `_isRecording`, `_currentIndex`)
- **Constants**: camelCase for class constants (e.g., `AppColors.primary`)
- **Static Constants**: camelCase (e.g., `static const Uuid _uuid`)

### Method Naming
- **Methods**: camelCase, verb-based (e.g., `loadGoals()`, `saveRecord()`)
- **Private Methods**: Prefix with underscore (e.g., `_buildHeader()`, `_loadData()`)
- **Build Methods**: Prefix with `_build` (e.g., `_buildProgressSection()`)
- **Async Methods**: No special prefix, use `async` keyword

## Code Organization

### Import Order
1. Dart SDK imports (`dart:*`)
2. Flutter imports (`package:flutter/*`)
3. Third-party package imports (`package:*`)
4. Relative imports (`./*`, `../*`)

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';
import 'package:isar/isar.dart';

import '../models/isar_models.dart';
import '../services/isar_service.dart';
import '../utils/app_colors.dart';
```

### Class Structure Order
1. Static constants
2. Instance variables (public then private)
3. Constructor
4. Lifecycle methods (`initState`, `dispose`, etc.)
5. Public methods
6. Private methods
7. Build methods (for widgets)

```dart
class ExampleScreen extends StatefulWidget {
  // 1. Static constants
  static const String routeName = '/example';
  
  // 2. Instance variables
  final String title;
  
  // 3. Constructor
  const ExampleScreen({Key? key, required this.title}) : super(key: key);
  
  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  // 1. Static constants
  static const int maxAttempts = 21;
  
  // 2. Instance variables
  int _currentIndex = 0;
  List<Goal> _goals = [];
  
  // 3. Lifecycle methods
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  // 4. Public methods
  void refreshData() {
    _loadData();
  }
  
  // 5. Private methods
  Future<void> _loadData() async {
    // Implementation
  }
  
  // 6. Build methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
    );
  }
  
  Widget _buildContent() {
    // Implementation
  }
}
```

## Widget Patterns

### Stateless vs Stateful
- **Use StatelessWidget when**:
  - Widget only displays data passed via constructor
  - No internal state changes
  - Pure presentation component
  
- **Use StatefulWidget when**:
  - Widget manages internal state
  - Needs lifecycle methods
  - Responds to user interactions that change state

### Widget Composition
- Break down complex widgets into smaller `_build*()` methods
- Extract reusable components into separate widget files
- Keep `build()` method focused and readable

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
          _buildActionButton(),
        ],
      ),
    ),
    bottomNavigationBar: _buildBottomNav(),
  );
}
```

### Constructor Patterns
- Always include `Key? key` parameter
- Use `required` for mandatory parameters
- Use named parameters for clarity
- Call `super(key: key)` in constructor

```dart
class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  
  const GoalCard({
    Key? key,
    required this.goal,
    this.onTap,
  }) : super(key: key);
}
```

## Async Patterns

### Async Method Signatures
```dart
// Good: Clear return type
Future<List<Goal>> getAllGoals() async { }
Future<void> saveGoal(Goal goal) async { }
Future<String?> getVideoPath(String assetId) async { }

// Avoid: Missing Future wrapper
List<Goal> getAllGoals() async { } // Wrong!
```

### Error Handling
```dart
Future<void> _loadData() async {
  try {
    final data = await IsarService.getAllGoals();
    setState(() {
      goals = data;
    });
  } catch (e) {
    debugPrint('Error loading goals: $e');
    // Optionally show error to user
  }
}
```

### Null Safety
- Use `?` for nullable types
- Use `!` only when absolutely certain value is non-null
- Prefer null-aware operators (`??`, `?.`)
- Use `late` for variables initialized before use

```dart
// Good
String? videoPath;
final path = videoPath ?? 'default.mp4';
final length = videoPath?.length ?? 0;

// Avoid
String videoPath; // Error: must be initialized
final length = videoPath!.length; // Risky: may throw
```

## UI/UX Patterns

### Color Usage
- Always use `AppColors` constants
- Never hardcode color values in widgets
- Use semantic color names (primary, background, textPrimary)

```dart
// Good
Container(
  color: AppColors.background,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)

// Avoid
Container(
  color: Color(0xFF122117), // Hardcoded
)
```

### Spacing & Sizing
- Use consistent spacing values: 4, 8, 12, 16, 20, 24
- Use `EdgeInsets` for padding/margin
- Use `SizedBox` for spacing between widgets

```dart
// Good
Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Title'),
      const SizedBox(height: 12),
      Text('Content'),
    ],
  ),
)
```

### Text Styles
- Define text styles inline with consistent properties
- Always specify: color, fontSize, fontWeight, height
- Use Manrope font family (default in theme)

```dart
Text(
  'Goal Title',
  style: const TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.28,
  ),
)
```

### Navigation
- Use `Navigator.push()` with `MaterialPageRoute`
- Use `.then()` to refresh data after navigation
- Always pass required data via constructor

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GoalDetailScreen(goal: goal),
  ),
).then((_) => _loadGoals());
```

## Service Patterns

### IsarService Pattern
- All methods are static
- Always use try-catch for database operations
- Generate UUIDs automatically if missing
- Use transactions for write operations

```dart
static Future<int> saveGoal(Goal goal) async {
  try {
    goal.uuid; // Check if initialized
  } catch (e) {
    goal.uuid = _uuid.v4(); // Generate if missing
  }
  
  return await isar.writeTxn(() async {
    return await isar.goals.put(goal);
  });
}
```

### CameraService Pattern
- Instance-based service
- Track internal state (e.g., `_isRecording`)
- Always dispose resources
- Use debug logging for troubleshooting

```dart
class CameraService {
  CameraController? controller;
  bool _isRecording = false;
  
  bool get isRecording => _isRecording;
  
  Future<void> initialize() async {
    try {
      // Initialize camera
      debugPrint('Camera initialized');
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
  
  Future<void> dispose() async {
    await controller?.dispose();
  }
}
```

## Testing Conventions

### Test File Naming
- Test files should mirror source file structure
- Use `_test.dart` suffix (e.g., `goal_card_test.dart`)

### Test Organization
- Group related tests with `group()`
- Use descriptive test names with `test()`
- Follow Arrange-Act-Assert pattern

```dart
void main() {
  group('GoalCard', () {
    test('displays goal title', () {
      // Arrange
      final goal = Goal()..title = 'Test Goal';
      
      // Act
      final widget = GoalCard(goal: goal);
      
      // Assert
      expect(find.text('Test Goal'), findsOneWidget);
    });
  });
}
```

## Documentation

### Code Comments
- Use `//` for single-line comments
- Use `///` for documentation comments
- Comment complex logic, not obvious code
- Explain "why", not "what"

```dart
// Good: Explains reasoning
// Use RouteObserver to automatically refresh data when returning from child routes
routeObserver.subscribe(this, ModalRoute.of(context)!);

// Avoid: States the obvious
// Set current index to 0
_currentIndex = 0;
```

### TODO Comments
- Use `// TODO:` for future improvements
- Include context or ticket reference

```dart
// TODO: Add error handling for network failures
// TODO: Implement cloud sync (Issue #123)
```

## Performance Best Practices

### Widget Rebuilds
- Use `const` constructors when possible
- Extract static widgets to const variables
- Avoid creating widgets in build methods unnecessarily

```dart
// Good
static const SizedBox spacing = SizedBox(height: 16);

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Title'),
      spacing,
      Text('Content'),
    ],
  );
}
```

### List Performance
- Use `ListView.builder` for long lists
- Avoid `ListView(children: [...])` for dynamic lists
- Use keys for list items when order changes

```dart
// Good
ListView.builder(
  itemCount: goals.length,
  itemBuilder: (context, index) {
    return GoalCard(
      key: ValueKey(goals[index].id),
      goal: goals[index],
    );
  },
)
```

### Resource Management
- Always dispose controllers (Camera, VideoPlayer)
- Unsubscribe from observers in dispose()
- Cancel timers and streams in dispose()

```dart
@override
void dispose() {
  _videoController?.dispose();
  _cameraService.dispose();
  routeObserver.unsubscribe(this);
  super.dispose();
}
```

## Git Conventions

### Commit Messages
- Use present tense ("Add feature" not "Added feature")
- Start with verb (Add, Fix, Update, Remove, Refactor)
- Keep first line under 50 characters
- Add detailed description if needed

```
Add video recording functionality

- Implement CameraService for video capture
- Add RecordScreen with camera preview
- Save videos to photo library with assetId
```

### Branch Naming
- Use descriptive names with hyphens
- Prefix with type: `feature/`, `fix/`, `refactor/`
- Examples: `feature/goal-creation`, `fix/video-playback`
