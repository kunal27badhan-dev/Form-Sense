# GitHub Copilot Instructions

This repository contains the Flutter framework source code and a sample Flutter application.

## Project Structure

- **`flutter/`** - The Flutter framework repository (main framework source)
- **`coolapp/`** - Sample Flutter application with Firebase integration

## Build, Test, and Lint Commands

### Flutter Framework (`flutter/`)

**Setup:**
```bash
cd flutter
flutter update-packages  # Fetch all Dart packages
```

**Testing:**
```bash
# Run all framework tests (same as CI)
dart dev/bots/test.dart

# Run specific test shards (examples)
SHARD=framework_tests flutter test
SHARD=framework_tests SUBSHARD=widgets flutter test
SHARD=web_tests SUBSHARD=2 flutter test

# Run single test file
flutter test packages/flutter/test/material/app_test.dart
```

**Analysis:**
```bash
# Run static analysis (same as CI)
dart --enable-asserts dev/bots/analyze.dart

# Analyze specific package
cd packages/flutter && flutter analyze
```

**IDE Setup:**
```bash
flutter ide-config --overwrite  # Generate IntelliJ config files
```

### Sample App (`coolapp/`)

**Setup:**
```bash
cd coolapp
flutter pub get  # Install dependencies
```

**Testing:**
```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Run single test
```

**Running:**
```bash
flutter run                     # Run on connected device/emulator
flutter run -d chrome          # Run on web browser
```

**Analysis:**
```bash
flutter analyze                 # Static analysis with flutter_lints
```

**Build:**
```bash
flutter build apk              # Android APK
flutter build web              # Web build
flutter build ios             # iOS (on macOS)
```

## Architecture

### Flutter Framework (`flutter/`)
- **`packages/`** - Core Flutter packages (flutter, flutter_test, flutter_tools, etc.)
- **`dev/`** - Development tools, bots, and testing infrastructure
- **`examples/`** - Example applications demonstrating framework features
- **`bin/`** - Flutter command-line tools
- Uses Dart with strict analysis options and comprehensive linting

### Sample App (`coolapp/`)
- **Architecture:** Fitness/workout tracking app ("FormSenseApp") with Firebase integration
- **Navigation Flow:** `SplashScreen` → `LoginPage` → `RegisterPage`|`HomePage`
- **Key Dependencies:** 
  - `video_player` - For splash screen video
  - `firebase_core`, `firebase_auth`, `cloud_firestore` - Authentication & database
  - `camera` - Camera functionality for workout form analysis
- **Firebase Integration:** Initialized in `main.dart` with platform-specific configuration
- **Navigation:** Named routes in `main.dart` + direct navigation
- **Named Routes Available:**
  - `/home` - Main dashboard (HomePage)
  - `/camera` - Camera screen for workout recording
  - `/running` - Running dashboard
  - `/meals` - Meals/nutrition dashboard
  - `/progress` - Progress tracking dashboard
  - `/programs` - Workout programs dashboard

## Key Conventions

### Flutter Framework
- **Test Organization:** Tests mirror source structure in `test/` directories
- **Shard-based Testing:** Large test suites split into shards for parallel execution
- **Strict Analysis:** Uses comprehensive linter rules with strict type checking
- **File Naming:** Snake_case for files, PascalCase for classes
- **Documentation:** Extensive inline documentation required for public APIs

### Sample App (`coolapp/`)
- **Asset Management:** All assets declared in `pubspec.yaml` under specific paths
  - Videos: `assets/videos/`
  - Images: `assets/images/`
- **Firebase Config:** Generated files in `lib/firebase_options.dart` (don't edit manually)
- **Authentication:** Hard-coded demo users in register flow (`kunal_27`, `7827`)
- **UI Pattern:** `AuthBackground` widget provides consistent auth screen styling
- **Theme:** Uses `ThemeData.dark()` globally

#### HomePage Design (Recently Updated)
The `lib/screens/home_page.dart` has been completely redesigned with modern UI/UX:

**Design Features:**
- **Stateful widget** with `TickerProviderStateMixin` for animations
- **Animated background** with pulsating radial gradient
- **Stats dashboard** showing workout count, average score, and streak
- **Hero card** (260px height) with:
  - Multi-color gradient (green → cyan → purple)
  - Animated pulsing glow effect
  - Glassmorphism with backdrop blur
  - "Start Workout" CTA button linked to camera
- **Quick Actions grid** (4 cards at 115px height each):
  - Running (green → teal gradients)
  - Programs (teal → purple gradients)
  - Progress (purple gradients)
  - Meals (orange gradients)
  - Enhanced glassmorphism with stronger blur (sigmaX: 20)
  - White semi-transparent overlays for frosted glass effect
- **Recent Activity section** with:
  - Activity cards showing workout history
  - Progress bars with percentage indicators
  - Color-coded by activity type
- **Bottom navigation** with 5 items and centered floating action button
- **Floating Action Button** with animated gradient and pulsing glow

**Color Palette (Toned Down):**
- Background Dark: `#0E141B`
- Card Dark: `#1B2430`
- Accent Green: `#4CAF50` (Material Design green)
- Accent Cyan/Teal: `#26A69A`
- Accent Purple: `#7E57C2`
- Accent Orange: `#FF9800`
- Soft Text: `#B6C2CF`

**Technical Details:**
- Two animation controllers: `_pulseController` (2000ms loop) and `_slideController` (800ms)
- Bouncing scroll physics for smooth scrolling
- `_Pressable` widget for tap animations (scale + opacity)
- All overflow issues fixed (hero card 260px, action cards 115px)
- Professional glassmorphism with proper blur, borders, and shadows

### Development Workflow
- **Framework:** Use `flutter update-packages` after dependency changes
- **Sample App:** Use `flutter pub get` after pubspec.yaml changes
- **Firebase Updates:** Use `flutterfire configure` instead of manual config edits
- **Platform Support:** Sample app supports Android/iOS/Web/Windows/macOS (Linux not configured for Firebase)

## Firebase Integration Notes

The sample app uses Firebase with platform-specific configuration:
- **Configuration:** `lib/firebase_options.dart` + platform files (`android/app/google-services.json`, etc.)
- **Regeneration:** Use `flutterfire configure` when Firebase project settings change
- **Supported Platforms:** Android, iOS, macOS, Web, Windows (Linux not configured)

## Testing Notes

### Framework Testing
- **Widget Tests:** Use `flutter_test` package with headless shell
- **Golden Tests:** Pixel-perfect UI comparisons
- **Integration Tests:** End-to-end testing with `flutter_driver`
- **Coverage:** Test coverage tracking available

### Sample App Testing
- **Current State:** Default counter app test (not aligned with actual UI)
- **Recommendation:** Update `test/widget_test.dart` to match current screen flow

## Important Project Notes

### Directory Status
- **`coolapp/`** - ACTIVE development app with updated modern UI design
- **`newapp/`** - DO NOT MODIFY - Keep as backup/reference with original design
- Both apps are identical in structure but `coolapp` has the enhanced home page design

### Recent Work Completed
- HomePage completely redesigned with modern glassmorphism UI
- Colors toned down from neon-bright to professional Material Design palette
- Enhanced glassmorphism effects on Quick Action cards (blur sigmaX: 20)
- Fixed all overflow issues (hero card: 260px, action cards: 115px)
- Added smooth animations with two controllers (pulse and slide)
- Floating Action Button with animated gradient pulsing effect