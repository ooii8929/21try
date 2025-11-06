# 21 Try App - Steering Documentation

This directory contains comprehensive documentation for the 21 Try App, designed to guide AI-assisted development and maintain consistency across the codebase.

## Documentation Structure

### Core Documentation (Always Included)

#### `product.md`
Product vision, user flows, and design principles. Read this to understand:
- What the app does and why
- Who the users are
- Key user journeys
- Success metrics

#### `tech.md`
Technology stack and architectural decisions. Read this to understand:
- Flutter/Dart versions and dependencies
- Database (Isar) and media handling
- Architecture patterns
- Platform-specific considerations

#### `structure.md`
Project organization and code architecture. Read this to understand:
- Directory structure and file organization
- Layer responsibilities (models, services, screens, widgets)
- Navigation architecture
- Data flow patterns
- State management strategy

#### `standards.md`
Coding conventions and best practices. Read this to understand:
- Naming conventions
- Code organization patterns
- Widget patterns
- Async/await patterns
- UI/UX standards
- Git conventions

### Context-Specific Documentation (Conditionally Included)

#### `data-models.md`
**Included when**: Working with files matching `**/*models*.dart`

Detailed reference for Isar database models:
- Goal and Record model specifications
- Relationship management
- UUID strategy
- Video asset management
- Code generation process

#### `ui-patterns.md`
**Included when**: Working with files in `screens/` or `widgets/` directories

UI component patterns and guidelines:
- Screen layout patterns
- Common UI components
- Form input patterns
- Video player setup
- Navigation patterns
- Loading and empty states

## How to Use This Documentation

### For New Features
1. Start with `product.md` to understand user needs
2. Review `tech.md` for technology constraints
3. Check `structure.md` for where code should live
4. Follow `standards.md` for implementation details
5. Reference context-specific docs as needed

### For Bug Fixes
1. Check `structure.md` to locate relevant code
2. Review `standards.md` for proper patterns
3. Reference context-specific docs for detailed guidance

### For Refactoring
1. Review `structure.md` for architectural patterns
2. Follow `standards.md` for consistency
3. Ensure changes align with `product.md` vision

## Key Principles

### 1. Offline-First Architecture
- All data stored locally in Isar database
- Videos saved to device photo library
- No network dependencies for core functionality

### 2. Simple State Management
- Local state with setState
- Database as source of truth
- Route-aware automatic refresh

### 3. Consistent UI Patterns
- Dark theme with green accents
- Standard screen layout structure
- Reusable component patterns

### 4. Video-Centric Experience
- Camera integration for recording attempts
- Video playback for review
- Asset ID-based video management

### 5. Progress Tracking
- 21 attempts per goal
- Visual progress indicators
- Timeline-based attempt history

## Common Tasks

### Adding a New Screen
1. Create file in `lib/screens/` following naming convention
2. Extend StatefulWidget with RouteAware mixin
3. Follow standard screen structure from `ui-patterns.md`
4. Use AppColors for consistent theming
5. Implement data loading in initState and didPopNext

### Adding a New Model
1. Add to `lib/models/isar_models.dart`
2. Use @Collection() annotation
3. Include part directive for generated code
4. Run build_runner to generate schema
5. Add CRUD methods to IsarService

### Adding a New Widget
1. Create file in `lib/widgets/`
2. Prefer StatelessWidget when possible
3. Accept data via constructor parameters
4. Use callbacks for interactions
5. Follow component patterns from `ui-patterns.md`

### Working with Video
1. Use CameraService for recording
2. Save to photo library to get assetId
3. Store assetId in Record model
4. Retrieve video path for playback
5. Properly dispose video controllers

## Development Workflow

### Before Starting
- Read relevant steering docs
- Understand the user flow
- Check existing patterns

### During Development
- Follow naming conventions
- Use consistent spacing and styling
- Add debug logging for troubleshooting
- Handle errors gracefully

### Before Committing
- Run flutter analyze
- Test on device/simulator
- Verify video recording/playback
- Check database operations
- Write descriptive commit message

## Testing Strategy

### Unit Tests
- Test service methods
- Test model creation and relationships
- Test utility functions

### Widget Tests
- Test UI components in isolation
- Verify user interactions
- Check conditional rendering

### Integration Tests
- Test complete user flows
- Verify database operations
- Test video recording and playback

## Future Considerations

### Cloud Sync
- UUID strategy already in place
- Will need backend API
- Sync strategy for conflicts
- Video upload/download

### Multi-Platform
- Android support (iOS-first currently)
- Platform-specific UI adaptations
- Permission handling differences

### Enhanced Features
- Goal categories/tags
- Social sharing
- Analytics and insights
- Reminders and notifications

## Questions?

When in doubt:
1. Check if there's a similar pattern in existing code
2. Review the relevant steering document
3. Follow the principle of least surprise
4. Maintain consistency with existing patterns

## Maintenance

These steering documents should be updated when:
- New architectural patterns are introduced
- Technology stack changes
- New conventions are established
- Product direction shifts

Keep documentation in sync with code to maintain its value as a development guide.
