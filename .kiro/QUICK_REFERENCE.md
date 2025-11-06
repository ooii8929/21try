# Quick Reference Card

## 🎯 Spec Commands

### Create New Spec
```
"Create a spec for [feature-name]"
"I want to add [description], create a spec"
```

### Execute Tasks
```
"Execute task 1 from [spec-name]"
"What's the next task in [spec-name]?"
"Continue with the next task"
```

### Update Specs
```
"Update requirements for [spec-name]"
"Modify the design for [spec-name]"
"Add a task to [spec-name]"
```

## 📚 Documentation Commands

### View Documentation
```
"What's in the steering docs?"
"Show me the UI patterns"
"What are the coding standards?"
```

### Update Documentation
```
"Update the coding standards to include [pattern]"
"Add [convention] to the structure docs"
```

## 🏗️ Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models (Isar)
├── services/              # Business logic
│   ├── isar_service.dart  # Database operations
│   └── camera_service.dart # Camera & media
├── screens/               # Full-screen pages
├── widgets/               # Reusable components
└── utils/                 # Constants & helpers
    └── app_colors.dart    # Color system
```

## 🎨 Key Patterns

### Screen Structure
```dart
class FeatureScreen extends StatefulWidget {
  @override
  State<FeatureScreen> createState() => _FeatureScreenState();
}

class _FeatureScreenState extends State<FeatureScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void didPopNext() {
    _loadData(); // Refresh on return
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildContent()),
      bottomNavigationBar: BottomNavBar(...),
    );
  }
}
```

### Service Pattern
```dart
// IsarService - Static methods
final goals = await IsarService.getAllGoals();
await IsarService.saveGoal(goal);

// CameraService - Instance methods
final camera = CameraService();
await camera.initializeCamera(CameraLensDirection.back);
await camera.dispose();
```

### Navigation Pattern
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailScreen(data: data),
  ),
).then((_) => _loadData()); // Refresh after return
```

## 🎨 Design System

### Colors
```dart
AppColors.background       // #122117 - Dark green
AppColors.cardBackground   // #24472E - Card bg
AppColors.primary          // #12ED5C - Bright green
AppColors.textPrimary      // #FFFFFF - White
AppColors.textSecondary    // #91C9A3 - Light green
```

### Typography
```dart
TextStyle(
  color: AppColors.textPrimary,
  fontSize: 18,
  fontWeight: FontWeight.w700,
  height: 1.28,
)
```

### Spacing
- Standard: 4, 8, 12, 16, 20, 24
- Screen padding: 16px horizontal
- Button padding: 20px horizontal

## 💾 Data Models

### Goal
```dart
Goal()
  ..uuid = 'auto-generated'
  ..title = 'Goal title'
  ..createdAt = DateTime.now()
  ..records = IsarLinks<Record>()
```

### Record
```dart
Record()
  ..uuid = 'auto-generated'
  ..title = 'Attempt title'
  ..description = 'Notes'
  ..assetId = 'video-asset-id'
  ..createdAt = DateTime.now()
  ..goal = IsarLink<Goal>()
```

## 🧪 Testing

### Run Tests
```bash
flutter test                    # All tests
flutter test --coverage         # With coverage
flutter test path/to/test.dart  # Specific test
```

### Test Pattern
```dart
void main() {
  group('Feature', () {
    test('does something', () {
      // Arrange
      final data = createTestData();
      
      // Act
      final result = performAction(data);
      
      // Assert
      expect(result, expectedValue);
    });
  });
}
```

## 🔧 Common Tasks

### Add New Screen
1. Create `lib/screens/feature_screen.dart`
2. Extend `StatefulWidget` with `RouteAware`
3. Follow standard screen structure
4. Use `AppColors` for theming

### Add New Model
1. Add to `lib/models/isar_models.dart`
2. Use `@Collection()` annotation
3. Run: `flutter pub run build_runner build --delete-conflicting-outputs`
4. Add CRUD methods to `IsarService`

### Add New Widget
1. Create `lib/widgets/component.dart`
2. Prefer `StatelessWidget`
3. Accept data via constructor
4. Use callbacks for interactions

### Work with Video
1. Record: `CameraService.startVideoRecording()`
2. Stop: `CameraService.stopVideoRecording()` → path
3. Save: `CameraService.saveVideoToGallery(path)` → assetId
4. Store assetId in Record model
5. Retrieve: `CameraService.getVideoPathFromAssetId(assetId)`

## 📖 Documentation Files

### Always Active
- `product.md` - Product vision
- `tech.md` - Technology stack
- `structure.md` - Architecture
- `standards.md` - Coding conventions

### Context-Aware
- `data-models.md` - When working with models
- `ui-patterns.md` - When working with UI
- `testing.md` - When writing tests

## 🚀 Workflow

### Spec-Driven Development
1. **Requirements** - Define user stories & acceptance criteria
2. **Design** - Create technical design
3. **Tasks** - Break down into steps
4. **Execute** - Implement one task at a time
5. **Review** - Check each task before continuing

### Quick Changes
For simple fixes, work directly without specs:
```
"Fix the bug in [file]"
"Update the color in [component]"
"Add logging to [method]"
```

## 💡 Tips

- ✅ Review requirements, design, and tasks before implementation
- ✅ Execute one task at a time
- ✅ Update steering docs when patterns change
- ✅ Use consistent naming and structure
- ✅ Always dispose resources (camera, video player)
- ✅ Test on device for camera features

## 🆘 Getting Help

```
"How do I [task]?"
"What's the pattern for [feature]?"
"Show me an example of [component]"
"What are the guidelines for [topic]?"
```

## 📱 App-Specific

### 21 Try Method
- Each goal has 21 attempts
- Videos stored in photo library
- Progress tracked automatically
- Timeline view of all attempts

### Key User Flows
1. Create Goal → View Progress → Record Try → Add Notes
2. View Goal → Edit Past Attempt → Update Notes
3. Home → Goal Detail → Timeline → Review

### Data Flow
```
Screen → Service → Database → Service → Screen
       ↓
    setState()
```

---

**Quick Access**: Save this file for fast reference during development!
