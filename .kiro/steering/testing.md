---
inclusion: fileMatch
fileMatchPattern: "**/*test*.dart"
---

# Testing Guidelines

## Testing Philosophy

### Test Pyramid
- **Unit Tests**: 70% - Fast, isolated, test business logic
- **Widget Tests**: 20% - Test UI components and interactions
- **Integration Tests**: 10% - Test complete user flows

### What to Test
- Business logic in services
- Data model relationships
- UI component rendering
- User interactions
- Error handling
- Edge cases

### What Not to Test
- Third-party library internals
- Flutter framework behavior
- Generated code (*.g.dart files)
- Trivial getters/setters

## Test File Organization

### File Structure
```
test/
├── unit/
│   ├── services/
│   │   ├── isar_service_test.dart
│   │   └── camera_service_test.dart
│   └── models/
│       └── isar_models_test.dart
├── widget/
│   ├── screens/
│   │   ├── home_screen_test.dart
│   │   └── goal_detail_screen_test.dart
│   └── widgets/
│       ├── goal_card_test.dart
│       └── bottom_nav_bar_test.dart
└── integration/
    ├── goal_creation_flow_test.dart
    └── record_attempt_flow_test.dart
```

### Naming Conventions
- Test files: `{source_file}_test.dart`
- Test groups: Describe the class or feature being tested
- Test cases: Describe the expected behavior

## Unit Testing

### Service Testing Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_one_try/services/isar_service.dart';
import 'package:twenty_one_try/models/isar_models.dart';

void main() {
  group('IsarService', () {
    setUpAll(() async {
      // Initialize test database
      await IsarService.initialize();
    });
    
    tearDownAll(() async {
      // Clean up test database
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.clear();
      });
    });
    
    group('Goal operations', () {
      test('saveGoal creates new goal with UUID', () async {
        // Arrange
        final goal = Goal()
          ..title = 'Test Goal'
          ..createdAt = DateTime.now();
        
        // Act
        final id = await IsarService.saveGoal(goal);
        
        // Assert
        expect(id, greaterThan(0));
        expect(goal.uuid, isNotEmpty);
        
        final savedGoal = await IsarService.getGoalById(id);
        expect(savedGoal, isNotNull);
        expect(savedGoal!.title, 'Test Goal');
      });
      
      test('getAllGoals returns all saved goals', () async {
        // Arrange
        await IsarService.saveGoal(Goal()..title = 'Goal 1');
        await IsarService.saveGoal(Goal()..title = 'Goal 2');
        
        // Act
        final goals = await IsarService.getAllGoals();
        
        // Assert
        expect(goals.length, greaterThanOrEqualTo(2));
      });
      
      test('deleteGoal removes goal from database', () async {
        // Arrange
        final goal = Goal()..title = 'To Delete';
        final id = await IsarService.saveGoal(goal);
        
        // Act
        final deleted = await IsarService.deleteGoal(id);
        
        // Assert
        expect(deleted, true);
        final retrieved = await IsarService.getGoalById(id);
        expect(retrieved, isNull);
      });
    });
    
    group('Record operations', () {
      test('saveRecordWithGoal creates relationship', () async {
        // Arrange
        final goal = Goal()..title = 'Parent Goal';
        final goalId = await IsarService.saveGoal(goal);
        
        final record = Record()
          ..title = 'Test Record'
          ..assetId = 'test-asset-id'
          ..description = 'Test description';
        
        // Act
        final recordId = await IsarService.saveRecordWithGoal(record, goalId);
        
        // Assert
        expect(recordId, greaterThan(0));
        
        final records = await IsarService.getRecordsByGoalId(goalId);
        expect(records.length, 1);
        expect(records.first.title, 'Test Record');
      });
    });
  });
}
```

### Model Testing Pattern

```dart
void main() {
  group('Goal Model', () {
    test('creates with default values', () {
      final goal = Goal()
        ..uuid = 'test-uuid'
        ..title = 'Test Goal';
      
      expect(goal.uuid, 'test-uuid');
      expect(goal.title, 'Test Goal');
      expect(goal.createdAt, isA<DateTime>());
    });
    
    test('can be updated', () {
      final goal = Goal()
        ..uuid = 'test-uuid'
        ..title = 'Original Title';
      
      goal.title = 'Updated Title';
      
      expect(goal.title, 'Updated Title');
    });
  });
  
  group('Record Model', () {
    test('creates with required fields', () {
      final record = Record()
        ..uuid = 'test-uuid'
        ..title = 'Test Record'
        ..assetId = 'asset-123';
      
      expect(record.uuid, 'test-uuid');
      expect(record.title, 'Test Record');
      expect(record.assetId, 'asset-123');
      expect(record.description, ''); // Default value
    });
  });
}
```

## Widget Testing

### Screen Testing Pattern

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_one_try/screens/home_screen.dart';
import 'package:twenty_one_try/services/isar_service.dart';

void main() {
  group('HomeScreen', () {
    setUpAll(() async {
      await IsarService.initialize();
    });
    
    testWidgets('displays app title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // Assert
      expect(find.text('Goals'), findsOneWidget);
    });
    
    testWidgets('displays goal cards', (tester) async {
      // Arrange
      await IsarService.saveGoal(Goal()..title = 'Test Goal');
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Test Goal'), findsOneWidget);
    });
    
    testWidgets('navigates to new goal screen on button tap', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // Act
      await tester.tap(find.text('New Goal'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('New goal'), findsOneWidget);
    });
  });
}
```

### Component Testing Pattern

```dart
void main() {
  group('GoalCard', () {
    testWidgets('displays goal title', (tester) async {
      // Arrange
      final goal = Goal()
        ..uuid = 'test-uuid'
        ..title = 'Learn Guitar';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalCard(goal: goal),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Learn Guitar'), findsOneWidget);
    });
    
    testWidgets('calls onTap when tapped', (tester) async {
      // Arrange
      bool tapped = false;
      final goal = Goal()..title = 'Test Goal';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalCard(
              goal: goal,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(GoalCard));
      
      // Assert
      expect(tapped, true);
    });
  });
  
  group('BottomNavBar', () {
    testWidgets('displays all navigation items', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavBar(
              currentIndex: 1,
              onTap: (_) {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
    
    testWidgets('calls onTap with correct index', (tester) async {
      // Arrange
      int? tappedIndex;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavBar(
              currentIndex: 1,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.home));
      
      // Assert
      expect(tappedIndex, 0);
    });
  });
}
```

## Integration Testing

### User Flow Testing Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:twenty_one_try/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Goal Creation Flow', () {
    testWidgets('user can create a new goal', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Act - Navigate to new goal screen
      await tester.tap(find.text('New Goal'));
      await tester.pumpAndSettle();
      
      // Act - Enter goal title
      await tester.enterText(
        find.byType(TextField),
        'Learn to play piano',
      );
      
      // Act - Save goal
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      
      // Assert - Goal appears in list
      expect(find.text('Learn to play piano'), findsOneWidget);
    });
  });
  
  group('Record Attempt Flow', () {
    testWidgets('user can record and save an attempt', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Create a goal first
      await tester.tap(find.text('New Goal'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test Goal');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      
      // Act - Navigate to goal detail
      await tester.tap(find.text('Test Goal'));
      await tester.pumpAndSettle();
      
      // Act - Start recording
      await tester.tap(find.text('Record Try'));
      await tester.pumpAndSettle();
      
      // Note: Actual camera recording requires device/emulator
      // Mock or skip camera interaction in tests
      
      // Assert - Verify navigation occurred
      expect(find.byType(RecordScreen), findsOneWidget);
    });
  });
}
```

## Mocking Patterns

### Mocking Services

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([IsarService, CameraService])
void main() {
  group('HomeScreen with mocks', () {
    late MockIsarService mockIsarService;
    
    setUp(() {
      mockIsarService = MockIsarService();
    });
    
    testWidgets('displays loading state', (tester) async {
      // Arrange
      when(mockIsarService.getAllGoals())
          .thenAnswer((_) async => Future.delayed(Duration(seconds: 1)));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen()),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

## Test Data Helpers

### Creating Test Data

```dart
class TestDataHelper {
  static Goal createTestGoal({
    String? uuid,
    String title = 'Test Goal',
    DateTime? createdAt,
  }) {
    return Goal()
      ..uuid = uuid ?? 'test-uuid-${DateTime.now().millisecondsSinceEpoch}'
      ..title = title
      ..createdAt = createdAt ?? DateTime.now();
  }
  
  static Record createTestRecord({
    String? uuid,
    String title = 'Test Record',
    String description = 'Test description',
    String assetId = 'test-asset-id',
    DateTime? createdAt,
  }) {
    return Record()
      ..uuid = uuid ?? 'test-uuid-${DateTime.now().millisecondsSinceEpoch}'
      ..title = title
      ..description = description
      ..assetId = assetId
      ..createdAt = createdAt ?? DateTime.now();
  }
  
  static Future<int> createTestGoalWithRecords({
    required String goalTitle,
    required int recordCount,
  }) async {
    final goal = createTestGoal(title: goalTitle);
    final goalId = await IsarService.saveGoal(goal);
    
    for (int i = 0; i < recordCount; i++) {
      final record = createTestRecord(
        title: 'Record ${i + 1}',
        assetId: 'asset-$i',
      );
      await IsarService.saveRecordWithGoal(record, goalId);
    }
    
    return goalId;
  }
}
```

## Running Tests

### Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/services/isar_service_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Run tests in watch mode (requires package)
flutter test --watch
```

### Coverage Goals
- Overall: 80%+
- Services: 90%+
- Models: 80%+
- Widgets: 70%+

## Best Practices

### Do's
- Write tests before fixing bugs (TDD for bug fixes)
- Test one thing per test case
- Use descriptive test names
- Clean up test data in tearDown
- Mock external dependencies
- Test error cases and edge cases
- Keep tests fast and independent

### Don'ts
- Don't test implementation details
- Don't write tests that depend on other tests
- Don't use real database for unit tests (use test instance)
- Don't skip cleanup in tearDown
- Don't test third-party code
- Don't make tests too complex

## Debugging Tests

### Common Issues

**Test fails intermittently**
- Check for timing issues with async operations
- Use `pumpAndSettle()` instead of `pump()`
- Ensure proper cleanup in tearDown

**Widget not found**
- Verify widget is actually rendered
- Check if widget is scrolled out of view
- Use `find.byKey()` for more reliable finding

**Database state issues**
- Clear database in tearDown
- Use unique test data for each test
- Initialize database in setUpAll

### Debug Output

```dart
testWidgets('debug example', (tester) async {
  await tester.pumpWidget(MyWidget());
  
  // Print widget tree
  debugDumpApp();
  
  // Print render tree
  debugDumpRenderTree();
  
  // Print layer tree
  debugDumpLayerTree();
});
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
        with:
          files: ./coverage/lcov.info
```

## Test Maintenance

### When to Update Tests
- When requirements change
- When bugs are found
- When refactoring code
- When adding new features

### Keeping Tests Maintainable
- Use test helpers for common setup
- Extract reusable test utilities
- Keep tests simple and focused
- Update tests with code changes
- Remove obsolete tests
