# Simple Flutter App for iOS

A simple Flutter application specifically configured for iOS development.

## Description

This is a basic Flutter counter application that demonstrates:
- Flutter Material Design widgets
- State management with StatefulWidget
- iOS-specific configuration and setup

## Project Structure

```
.
├── lib/
│   └── main.dart              # Main Flutter application code
├── ios/
│   ├── Runner/                # iOS native code and resources
│   ├── Runner.xcodeproj/      # Xcode project files
│   ├── Runner.xcworkspace/    # Xcode workspace
│   ├── Podfile                # CocoaPods dependency management
│   └── Flutter/               # Flutter iOS configuration
├── pubspec.yaml               # Flutter dependencies
└── analysis_options.yaml      # Dart linting rules
```

## Prerequisites

To build and run this application, you need:

1. **Flutter SDK** - Install from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. **Xcode** - Required for iOS development (macOS only)
3. **CocoaPods** - Install with `sudo gem install cocoapods`

## Getting Started

### 1. Install Flutter Dependencies

```bash
flutter pub get
```

### 2. Install iOS Dependencies

```bash
cd ios
pod install
cd ..
```

### 3. Run on iOS Simulator

```bash
flutter run -d ios
```

Or open the Xcode workspace and run from there:

```bash
open ios/Runner.xcworkspace
```

## Building for iOS

### Debug Build

```bash
flutter build ios --debug
```

### Release Build

```bash
flutter build ios --release
```

## Features

- Simple counter application
- Material Design UI
- Supports both iPhone and iPad
- iOS 12.0 and later

## Configuration

- **Bundle Identifier**: `com.example.simpleFlutterApp`
- **Minimum iOS Version**: 12.0
- **Supported Orientations**: Portrait, Landscape Left, Landscape Right

## License

This project is a simple demonstration application.