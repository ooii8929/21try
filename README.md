# 21 Try App

A Flutter goal tracking application based on the 21 try method. This app helps users set goals and track their progress through 21 attempts.

## Features

- **Goals Dashboard**: View all your goals with progress tracking
- **Goal Details**: See detailed progress and timeline for each goal
- **Record Tries**: Capture video or photo evidence of your attempts
- **Edit Records**: Add titles and notes to your tries
- **Create Goals**: Set new goals with a simple interface

## Getting Started

### Prerequisites

- Flutter SDK (>=2.17.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone this repository
2. Download Manrope font family and place the font files in `fonts/` directory:
   - Manrope-Regular.ttf (weight 400)
   - Manrope-Medium.ttf (weight 500)
   - Manrope-Bold.ttf (weight 700)

3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Font Setup

Download the Manrope font from [Google Fonts](https://fonts.google.com/specimen/Manrope) and create a `fonts` directory in the project root with the following files:
- `fonts/Manrope-Regular.ttf`
- `fonts/Manrope-Medium.ttf`
- `fonts/Manrope-Bold.ttf`

## Color Scheme

The app uses a dark green color palette:
- Background: #122117
- Card Background: #24472E
- Primary (Accent): #12ED5C
- Text Primary: #FFFFFF
- Text Secondary: #91C9A3

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── goal.dart
├── screens/
│   ├── home_screen.dart
│   ├── goal_detail_screen.dart
│   ├── record_screen.dart
│   ├── edit_record_screen.dart
│   └── new_goal_screen.dart
├── utils/
│   └── app_colors.dart
└── widgets/
    ├── goal_card.dart
    └── bottom_nav_bar.dart
```

## Screens

1. **Home Screen**: Displays all goals with progress indicators
2. **Goal Detail Screen**: Shows progress summary and timeline of tries
3. **Record Screen**: Interface for recording new tries
4. **Edit Record Screen**: Form to edit try details
5. **New Goal Screen**: Form to create a new goal

## License

This project is created for demonstration purposes.
