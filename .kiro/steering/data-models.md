---
inclusion: fileMatch
fileMatchPattern: "**/*models*.dart"
---

# Data Models Reference

## Isar Database Models

### Goal Model

**Purpose**: Represents a user's goal with a target of 21 attempts

**Collection**: `@Collection()`

**Fields**:
- `Id id`: Auto-increment local database ID (Isar.autoIncrement)
- `String uuid`: Stable unique identifier for cross-device sync
- `String title`: Goal name/description
- `DateTime createdAt`: Timestamp when goal was created
- `IsarLinks<Record> records`: One-to-many relationship to Record collection

**Relationships**:
- One Goal has many Records (attempts)
- Bidirectional relationship with Record model

**Usage Example**:
```dart
final goal = Goal()
  ..uuid = Uuid().v4()
  ..title = 'Learn to play guitar'
  ..createdAt = DateTime.now();

await IsarService.saveGoal(goal);
```

**Database Operations**:
- Create: `IsarService.saveGoal(goal)`
- Read All: `IsarService.getAllGoals()`
- Read One: `IsarService.getGoalById(id)`
- Delete: `IsarService.deleteGoal(id)`

### Record Model

**Purpose**: Represents a single attempt at achieving a goal

**Collection**: `@Collection()`

**Fields**:
- `Id id`: Auto-increment local database ID (Isar.autoIncrement)
- `String uuid`: Stable unique identifier for cross-device sync
- `String title`: Title/name for this attempt
- `String description`: Reflective notes about the attempt (default: '')
- `String assetId`: Photo library identifier for the video (required)
- `DateTime createdAt`: Timestamp when attempt was recorded
- `IsarLink<Goal> goal`: Many-to-one relationship to Goal collection

**Relationships**:
- Many Records belong to one Goal
- Bidirectional relationship with Goal model

**Usage Example**:
```dart
final record = Record()
  ..uuid = Uuid().v4()
  ..title = 'First attempt'
  ..description = 'Struggled with finger positioning'
  ..assetId = 'photo-library-asset-id'
  ..createdAt = DateTime.now();

await IsarService.saveRecordWithGoal(record, goalId);
```

**Database Operations**:
- Create: `IsarService.saveRecordWithGoal(record, goalId)`
- Read All: `IsarService.getAllRecords()`
- Read One: `IsarService.getRecordById(id)`
- Read by Goal: `IsarService.getRecordsByGoalId(goalId)`
- Update: `IsarService.saveRecord(record)` (with existing id)
- Delete: `IsarService.deleteRecord(id)`

## Relationship Management

### Loading Relationships

**Goal → Records**:
```dart
final goal = await IsarService.getGoalById(goalId);
await goal.records.load(); // Load related records
final recordsList = goal.records.toList();
```

**Record → Goal**:
```dart
final record = await IsarService.getRecordById(recordId);
await record.goal.load(); // Load parent goal
final parentGoal = record.goal.value;
```

### Creating Relationships

**When creating a new Record**:
```dart
// Use saveRecordWithGoal to automatically establish relationship
await IsarService.saveRecordWithGoal(record, goalId);

// This handles:
// 1. Saving the record
// 2. Linking record.goal to the Goal
// 3. Adding record to goal.records
```

## UUID Strategy

**Purpose**: Stable identifiers for future cloud synchronization

**Generation**: Automatic in IsarService if not provided
```dart
try {
  goal.uuid; // Check if initialized
} catch (e) {
  goal.uuid = _uuid.v4(); // Generate if missing
}
```

**Best Practice**: Let IsarService handle UUID generation automatically

## Video Asset Management

### Asset ID Storage
- Videos are saved to device photo library
- `assetId` stores the photo library identifier (localIdentifier)
- Use `CameraService.getVideoPathFromAssetId(assetId)` to retrieve video path

### Video Lifecycle
1. Record video with CameraService → get video path
2. Save to photo library → get assetId
3. Store assetId in Record model
4. Retrieve video path when needed for playback

```dart
// Recording and saving
final videoPath = await cameraService.stopVideoRecording();
final assetId = await cameraService.saveVideoToGallery(videoPath);

// Create record with assetId
final record = Record()
  ..assetId = assetId
  ..title = 'Attempt 1';

// Later: retrieve for playback
final videoPath = await cameraService.getVideoPathFromAssetId(record.assetId);
```

## Data Validation

### Required Fields
- **Goal**: uuid, title
- **Record**: uuid, title, assetId

### Default Values
- **Goal**: createdAt defaults to DateTime.now()
- **Record**: createdAt defaults to DateTime.now(), description defaults to ''

### Field Constraints
- All String fields use `late` keyword (must be initialized before use)
- DateTime fields have default values
- Id fields use Isar.autoIncrement

## Code Generation

### Generating Isar Code
After modifying models, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Generated Files
- Source: `lib/models/isar_models.dart`
- Generated: `lib/models/isar_models.g.dart`
- Never edit `.g.dart` files manually

### Part Directive
Always include at top of model file:
```dart
part 'isar_models.g.dart';
```

## Migration Strategy

### Adding New Fields
1. Add field to model class
2. Run build_runner to regenerate code
3. Isar handles schema migration automatically
4. Existing data preserved, new fields get default values

### Modifying Relationships
1. Update IsarLinks/IsarLink declarations
2. Run build_runner
3. Update service methods if needed
4. Test relationship loading/saving

## Performance Considerations

### Lazy Loading
- Relationships are NOT loaded by default
- Always call `.load()` before accessing relationship data
- Load only when needed to minimize database queries

### Batch Operations
- Use transactions for multiple writes
- IsarService wraps writes in `writeTxn()`
- Improves performance and ensures atomicity

### Indexing
- Currently no custom indexes defined
- Consider adding indexes for frequently queried fields
- Example: `@Index()` annotation on fields

## Testing Models

### Unit Testing
```dart
test('Goal model creates with default values', () {
  final goal = Goal()
    ..uuid = 'test-uuid'
    ..title = 'Test Goal';
  
  expect(goal.uuid, 'test-uuid');
  expect(goal.title, 'Test Goal');
  expect(goal.createdAt, isNotNull);
});
```

### Integration Testing
```dart
test('Record can be linked to Goal', () async {
  final goal = Goal()..uuid = 'g1'..title = 'Goal 1';
  final goalId = await IsarService.saveGoal(goal);
  
  final record = Record()
    ..uuid = 'r1'
    ..title = 'Record 1'
    ..assetId = 'asset-1';
  
  await IsarService.saveRecordWithGoal(record, goalId);
  
  final records = await IsarService.getRecordsByGoalId(goalId);
  expect(records.length, 1);
  expect(records.first.title, 'Record 1');
});
```
