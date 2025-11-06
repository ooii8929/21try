---
inclusion: fileMatch
fileMatchPattern: "**/{screens,widgets}/**/*.dart"
---

# UI Patterns & Component Guidelines

## Screen Layout Pattern

### Standard Screen Structure
Every screen follows this consistent structure:

```dart
class FeatureScreen extends StatefulWidget {
  const FeatureScreen({Key? key}) : super(key: key);
  
  @override
  State<FeatureScreen> createState() => _FeatureScreenState();
}

class _FeatureScreenState extends State<FeatureScreen> with RouteAware {
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
```

### Layout Components

#### Header Pattern
- Fixed height container at top
- Centered title with optional back button
- Optional action button (settings, etc.)
- Consistent padding: `EdgeInsets.fromLTRB(16, 16, 16, 8)`

```dart
Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    color: AppColors.background,
    child: Row(
      children: [
        // Back button (48x48)
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        // Centered title
        Expanded(
          child: Text(
            'Screen Title',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.28,
            ),
          ),
        ),
        // Optional action button or spacer
        const SizedBox(width: 48),
      ],
    ),
  );
}
```

#### Content Area Pattern
- Wrapped in `Expanded` widget
- Scrollable with `SingleChildScrollView` or `ListView`
- Horizontal padding: 16px

```dart
Widget _buildContent() {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection1(),
        _buildSection2(),
      ],
    ),
  );
}
```

#### Action Button Pattern
- Fixed at bottom above navigation bar
- Full-width with horizontal padding: 20px
- Height: 56px
- Primary color background with rounded corners (8px)
- Icon + text layout

```dart
Widget _buildActionButton() {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: GestureDetector(
      onTap: _handleAction,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.background, size: 24),
            SizedBox(width: 16),
            Text(
              'Action Text',
              style: TextStyle(
                color: AppColors.background,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

## Common UI Components

### Progress Indicator
Used to show completion progress (X/21 attempts)

```dart
Widget _buildProgressSection() {
  final progress = currentCount / 21.0;
  
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Almost there!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            Text(
              '$currentCount/21',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.progressBackground,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    ),
  );
}
```

### Timeline Item
Used to display chronological list of attempts

```dart
Widget _buildTimelineItem(Record record, int index) {
  return Container(
    margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left accent line
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record $index: ${record.title}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(record.createdAt),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                if (record.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Action button
          _buildEditButton(record),
        ],
      ),
    ),
  );
}

Widget _buildEditButton(Record record) {
  return GestureDetector(
    onTap: () => _handleEdit(record),
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.edit, color: AppColors.textPrimary, size: 20),
      ),
    ),
  );
}
```

### Card Component
Used for displaying goals in list view

```dart
class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  
  const GoalCard({Key? key, required this.goal, this.onTap}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progress info',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Optional: thumbnail or icon
          ],
        ),
      ),
    );
  }
}
```

## Form Input Patterns

### Text Input Field
```dart
Widget _buildTextField({
  required String label,
  required TextEditingController controller,
  int maxLines = 1,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    ],
  );
}
```

### Text Area (Multi-line Input)
```dart
TextField(
  controller: _descriptionController,
  maxLines: 5,
  minLines: 3,
  style: const TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
  decoration: InputDecoration(
    hintText: 'Add a note...',
    hintStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 16,
    ),
    filled: true,
    fillColor: AppColors.cardBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.all(16),
  ),
)
```

## Video Player Pattern

### Video Player Setup
```dart
class _VideoScreenState extends State<VideoScreen> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  
  Future<void> _initializePlayer() async {
    try {
      final videoPath = await CameraService().getVideoPathFromAssetId(assetId);
      if (videoPath == null) return;
      
      _videoController = VideoPlayerController.file(File(videoPath));
      await _videoController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
      );
      
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }
  
  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}
```

## Navigation Patterns

### Push Navigation with Data Refresh
```dart
void _navigateToDetail(Goal goal) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GoalDetailScreen(goal: goal),
    ),
  ).then((_) => _loadData()); // Refresh after returning
}
```

### Pop with Result
```dart
// In child screen
Navigator.pop(context, true); // Return result

// In parent screen
final result = await Navigator.push(...);
if (result == true) {
  _loadData();
}
```

## Loading States

### Loading Indicator
```dart
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
  
  return _buildContent();
}
```

### Empty State
```dart
Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 64,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 16),
        Text(
          'No items yet',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}
```

## Responsive Design

### Safe Area Usage
Always wrap content in `SafeArea` to avoid notches and system UI:
```dart
Scaffold(
  body: SafeArea(
    child: _buildContent(),
  ),
)
```

### Flexible Layouts
Use `Expanded` and `Flexible` for responsive sizing:
```dart
Row(
  children: [
    const SizedBox(width: 48), // Fixed
    Expanded(child: Text('Title')), // Flexible
    const SizedBox(width: 48), // Fixed
  ],
)
```

## Accessibility

### Semantic Labels
```dart
IconButton(
  icon: const Icon(Icons.settings),
  onPressed: _openSettings,
  tooltip: 'Settings',
)
```

### Text Contrast
- Always use AppColors for proper contrast
- Primary text: `AppColors.textPrimary` (white)
- Secondary text: `AppColors.textSecondary` (light green)
- Background: `AppColors.background` (dark green)

## Animation Guidelines

### Implicit Animations
Use for simple state changes:
```dart
AnimatedOpacity(
  opacity: _isVisible ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 300),
  child: _buildContent(),
)
```

### Page Transitions
Default MaterialPageRoute provides platform-appropriate transitions

## Testing UI Components

### Widget Tests
```dart
testWidgets('GoalCard displays goal title', (tester) async {
  final goal = Goal()..title = 'Test Goal';
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GoalCard(goal: goal),
      ),
    ),
  );
  
  expect(find.text('Test Goal'), findsOneWidget);
});
```

### Golden Tests
For visual regression testing:
```dart
testWidgets('GoalCard golden test', (tester) async {
  await tester.pumpWidget(MaterialApp(home: GoalCard(goal: testGoal)));
  await expectLater(find.byType(GoalCard), matchesGoldenFile('goal_card.png'));
});
```
