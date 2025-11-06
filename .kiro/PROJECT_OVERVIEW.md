# 21 Try App - Project Overview

## 📱 What is 21 Try?

A Flutter mobile app that helps users achieve goals through the **21 Try Method** - the principle that 21 documented attempts are sufficient to master any skill or achieve any goal.

### Core Concept
- Users create goals they want to achieve
- Each goal requires 21 video-documented attempts
- Users add reflective notes after each attempt
- Progress is tracked visually with timeline and progress bars

## 🎯 Current State

### ✅ Implemented Features
- **Goal Management**: Create, view, and track multiple goals
- **Video Recording**: Built-in camera for recording attempts
- **Attempt Documentation**: Add titles and notes to each attempt
- **Progress Tracking**: Visual progress bars (X/21 attempts)
- **Timeline View**: Chronological display of all attempts
- **Video Playback**: Review past attempts with video player
- **Local Storage**: Offline-first with Isar database
- **Photo Library Integration**: Videos saved to device gallery

### 🏗️ Architecture
- **Framework**: Flutter (Dart)
- **Database**: Isar (NoSQL, offline-first)
- **State Management**: Local state with setState
- **Navigation**: MaterialPageRoute with RouteObserver
- **Media**: Camera + Video Player + Photo Manager

### 📊 Data Model
```
Goal (1) ←→ (Many) Record
  ├─ id, uuid, title, createdAt
  └─ records: IsarLinks<Record>

Record
  ├─ id, uuid, title, description, assetId, createdAt
  └─ goal: IsarLink<Goal>
```

## 📁 Project Structure

```
21_try_app/
├── .kiro/                          # Kiro configuration & docs
│   ├── steering/                   # Project knowledge base
│   │   ├── product.md             # Product vision
│   │   ├── tech.md                # Technology stack
│   │   ├── structure.md           # Architecture
│   │   ├── standards.md           # Coding conventions
│   │   ├── data-models.md         # Model specifications
│   │   ├── ui-patterns.md         # UI guidelines
│   │   ├── testing.md             # Testing guidelines
│   │   └── README.md              # Documentation guide
│   ├── specs/                      # Feature specifications
│   ├── TRANSITION_GUIDE.md        # Vibe → Spec guide
│   ├── QUICK_REFERENCE.md         # Quick reference card
│   └── PROJECT_OVERVIEW.md        # This file
├── lib/
│   ├── main.dart                  # App entry point
│   ├── models/                    # Data models
│   │   ├── isar_models.dart       # Goal & Record
│   │   └── isar_models.g.dart     # Generated code
│   ├── services/                  # Business logic
│   │   ├── isar_service.dart      # Database operations
│   │   └── camera_service.dart    # Camera & media
│   ├── screens/                   # UI screens
│   │   ├── home_screen.dart       # Goals dashboard
│   │   ├── goal_detail_screen.dart # Progress & timeline
│   │   ├── new_goal_screen.dart   # Goal creation
│   │   ├── record_screen.dart     # Video recording
│   │   ├── edit_record_screen.dart # New attempt editing
│   │   └── edit_record_review_screen.dart # Edit existing
│   ├── widgets/                   # Reusable components
│   │   ├── goal_card.dart         # Goal display card
│   │   └── bottom_nav_bar.dart    # Navigation bar
│   └── utils/
│       └── app_colors.dart        # Color system
├── fonts/                         # Manrope font family
├── ios/                           # iOS platform code
├── test/                          # Tests
├── pubspec.yaml                   # Dependencies
└── README.md                      # Project README
```

## 🎨 Design System

### Color Palette
- **Background**: `#122117` - Dark green
- **Card Background**: `#24472E` - Medium green
- **Primary**: `#12ED5C` - Bright green (accent)
- **Text Primary**: `#FFFFFF` - White
- **Text Secondary**: `#91C9A3` - Light green

### Typography
- **Font**: Manrope (Regular 400, Medium 500, Bold 700)
- **Sizes**: 14px (small), 16px (body), 18px (heading)
- **Line Height**: 1.28 (headings), 1.5 (body)

### Spacing
- **Standard**: 4, 8, 12, 16, 20, 24px
- **Screen Padding**: 16px horizontal
- **Button Height**: 56px
- **Icon Size**: 24px (standard), 20px (small)

## 🔄 User Flows

### Primary Flow: Recording an Attempt
```
Home Screen
  ↓ (tap goal)
Goal Detail Screen
  ↓ (tap "Record Try")
Record Screen (camera)
  ↓ (record video)
Edit Record Screen
  ↓ (add title & notes)
Goal Detail Screen (updated)
```

### Secondary Flow: Creating a Goal
```
Home Screen
  ↓ (tap "New Goal")
New Goal Screen
  ↓ (enter title)
Home Screen (with new goal)
```

### Tertiary Flow: Reviewing Attempts
```
Goal Detail Screen
  ↓ (tap edit icon)
Edit Record Review Screen
  ↓ (modify notes)
Goal Detail Screen (updated)
```

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK (>=2.17.0)
- Dart SDK
- iOS development tools (Xcode)
- Android development tools (optional)

### Installation
```bash
# Install dependencies
flutter pub get

# Generate Isar code
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

### Key Commands
```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## 📚 Documentation

### For Developers
1. **Start Here**: `.kiro/TRANSITION_GUIDE.md`
2. **Quick Reference**: `.kiro/QUICK_REFERENCE.md`
3. **Deep Dive**: `.kiro/steering/README.md`

### For AI Assistants
- **Always Active**: product.md, tech.md, structure.md, standards.md
- **Context-Aware**: data-models.md, ui-patterns.md, testing.md
- **Spec-Driven**: Follow requirements → design → tasks workflow

## 🚀 Development Workflow

### Spec-Driven (Recommended for Features)
1. Create spec with requirements
2. Design technical solution
3. Break down into tasks
4. Execute tasks one at a time
5. Review and iterate

### Direct Development (For Quick Changes)
- Bug fixes
- Minor UI tweaks
- Simple updates
- Refactoring

## 🎯 Future Roadmap Ideas

### Potential Features
- **Goal Categories**: Organize goals by category/tags
- **Analytics**: Progress statistics and insights
- **Comparison**: Side-by-side attempt comparison
- **Reminders**: Notifications for recording attempts
- **Export**: Share progress and achievements
- **Cloud Sync**: Multi-device synchronization
- **Social**: Share goals with friends
- **Gamification**: Achievements and streaks

### Technical Improvements
- **Testing**: Increase test coverage
- **Performance**: Optimize video loading
- **Accessibility**: Improve screen reader support
- **Localization**: Multi-language support
- **Android**: Full Android platform support

## 📊 Project Metrics

### Current Stats
- **Screens**: 7 (6 active + 1 placeholder)
- **Models**: 2 (Goal, Record)
- **Services**: 2 (Isar, Camera)
- **Widgets**: 2 (GoalCard, BottomNavBar)
- **Dependencies**: 11 main + 3 dev

### Code Organization
- **Models**: Data structures and relationships
- **Services**: Business logic and external integrations
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components
- **Utils**: Constants and helpers

## 🔐 Permissions Required

### iOS (Info.plist)
- Camera usage
- Photo library access
- Microphone access (for video recording)

### Android (AndroidManifest.xml)
- Camera permission
- Storage permission
- Audio recording permission

## 🐛 Known Considerations

### Platform Limitations
- Camera features require physical device (not simulator)
- Video recording requires adequate storage space
- Photo library access requires user permission

### Technical Debt
- Limited error handling in some areas
- No network connectivity (offline-only)
- No data backup/restore functionality
- Limited video format support

## 📖 Learning Resources

### Flutter
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### Isar Database
- [Isar Documentation](https://isar.dev)
- [Isar Flutter Guide](https://isar.dev/tutorials/quickstart.html)

### Camera & Video
- [Camera Plugin](https://pub.dev/packages/camera)
- [Video Player](https://pub.dev/packages/video_player)
- [Chewie](https://pub.dev/packages/chewie)

## 🤝 Contributing

### Code Style
- Follow `.kiro/steering/standards.md`
- Use consistent naming conventions
- Write descriptive commit messages
- Add tests for new features

### Pull Request Process
1. Create feature branch
2. Implement changes following standards
3. Write/update tests
4. Update documentation
5. Submit PR with description

## 📞 Support

### Getting Help
- Check `.kiro/steering/` documentation
- Review `.kiro/QUICK_REFERENCE.md`
- Ask Kiro for guidance
- Consult Flutter documentation

### Common Issues
- **Camera not working**: Check permissions and use physical device
- **Database errors**: Ensure Isar is initialized
- **Video playback issues**: Verify assetId is valid
- **Build errors**: Run `flutter clean` and `flutter pub get`

## 🎉 Success Criteria

### User Success
- Users complete 21 attempts for goals
- Users add meaningful reflective notes
- Users review past attempts regularly
- Users achieve their goals

### Technical Success
- App runs smoothly on iOS devices
- No data loss or corruption
- Fast video recording and playback
- Intuitive user interface

## 📝 Version History

### Current Version: 1.0.0+1
- Initial release
- Core goal tracking functionality
- Video recording and playback
- Local database storage
- iOS support

---

**Last Updated**: November 6, 2025

**Project Status**: ✅ Active Development

**Documentation Status**: ✅ Complete

**Ready for Spec-Driven Development**: ✅ Yes
