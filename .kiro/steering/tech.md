# Technology Stack

## Framework & Language

### Flutter
- **Version**: SDK >=2.17.0 <3.0.0
- **Language**: Dart
- **Platform Support**: iOS (primary), Android (future)

## Core Dependencies

### Database & Persistence
- **Isar** (^3.1.0): Local NoSQL database for offline-first data storage
  - Fast, type-safe database with code generation
  - Supports relationships between collections
  - Used for Goal and Record models
- **isar_flutter_libs** (^3.1.0): Flutter-specific Isar bindings
- **path_provider** (^2.1.3): Access to device file system directories

### Media & Camera
- **camera** (^0.11.3): Camera access and video recording
- **video_player** (^2.7.0): Video playback functionality
- **chewie** (^1.8.1): Enhanced video player with controls
- **photo_manager** (^3.0.0): Photo library integration for saving/retrieving videos

### Utilities
- **uuid** (^4.5.1): Generate stable unique identifiers for cross-device sync readiness

## Development Tools

### Code Generation
- **isar_generator** (^3.1.0+1): Generates Isar database schemas
- **build_runner** (^2.4.9): Runs code generators

### Code Quality
- **flutter_lints** (^2.0.0): Recommended linting rules for Flutter

## Architecture Patterns

### Data Layer
- **Repository Pattern**: IsarService acts as repository for database operations
- **Service Layer**: Separate services for camera and database concerns
- **Model Layer**: Isar collections with relationships (Goal ↔ Record)

### UI Layer
- **Screen-Based Architecture**: Each major view is a separate screen widget
- **Stateful Widgets**: Local state management with setState
- **Route Observer Pattern**: Automatic refresh when returning from child routes

### State Management
- **Local State**: setState for screen-specific UI state
- **Route Awareness**: RouteObserver for detecting navigation events
- **Database as Source of Truth**: Always reload from database on screen focus

## Design System

### Typography
- **Font Family**: Manrope (Google Fonts)
- **Weights**: Regular (400), Medium (500), Bold (700)
- **Variable Font**: Included for future flexibility

### Color System
- Centralized in `AppColors` utility class
- Dark theme with green accent color
- Semantic color naming (background, primary, textPrimary, etc.)

## Platform-Specific Considerations

### iOS
- Camera and photo library permissions required in Info.plist
- Status bar styling configured for dark theme
- Podfile for native dependencies

### Future Android Support
- Camera permissions in AndroidManifest.xml
- Photo library permissions handling
- Platform-specific UI adaptations

## Build & Deployment

### Code Generation Commands
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running the App
```bash
flutter pub get
flutter run
```

## Technical Constraints

1. **Offline-First**: App must work without internet connection
2. **Local Storage**: All data stored locally using Isar
3. **Video Storage**: Videos saved to device photo library, referenced by assetId
4. **UUID Strategy**: Stable identifiers for future cloud sync capability
5. **Memory Management**: Proper disposal of camera and video player controllers
