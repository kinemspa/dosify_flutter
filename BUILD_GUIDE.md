# Dosify Flutter App - Comprehensive Build Guide

This document provides complete step-by-step instructions for building the Dosify Flutter medication management app from scratch.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Project Setup](#project-setup)
4. [Dependencies Installation](#dependencies-installation)
5. [Code Generation](#code-generation)
6. [Firebase Configuration](#firebase-configuration)
7. [Building the App](#building-the-app)
8. [Testing](#testing)
9. [Deployment](#deployment)
10. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements
- **Operating System**: Windows 10/11, macOS 10.14+, or Linux
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: At least 10GB free space
- **Internet Connection**: Required for downloading dependencies

### Required Software

#### 1. Flutter SDK
1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract to a permanent location (e.g., `C:\flutter` on Windows)
3. Add Flutter to your system PATH
4. Verify installation:
   ```bash
   flutter --version
   flutter doctor
   ```

#### 2. Dart SDK
- Included with Flutter SDK
- Verify with: `dart --version`

#### 3. Git
1. Download from [git-scm.com](https://git-scm.com/)
2. Install with default settings
3. Verify: `git --version`

#### 4. IDE/Editor (Choose one)
- **Android Studio** (Recommended)
  - Download from [developer.android.com](https://developer.android.com/studio)
  - Install Flutter and Dart plugins
- **VS Code**
  - Download from [code.visualstudio.com](https://code.visualstudio.com/)
  - Install Flutter and Dart extensions

#### 5. Platform-Specific Tools

**For Android:**
- Android Studio with Android SDK
- Android SDK Platform Tools
- Android Emulator or physical device

**For iOS (macOS only):**
- Xcode 12.0 or later
- iOS Simulator or physical device
- CocoaPods: `sudo gem install cocoapods`

## Environment Setup

### 1. Flutter Doctor Check
Run and resolve all issues:
```bash
flutter doctor
```

### 2. Accept Android Licenses
```bash
flutter doctor --android-licenses
```

### 3. Enable Developer Options (Physical Devices)
- Android: Settings > About > Tap Build Number 7 times
- iOS: Settings > General > About > Tap Version 7 times

## Project Setup

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/dosify_flutter.git
cd dosify_flutter
```

### 2. Verify Flutter Version
Ensure you're using the correct Flutter version:
```bash
flutter --version
```
Required: Flutter 3.0.0 or later

### 3. Check Project Structure
Verify the following directories exist:
```
dosify_flutter/
├── lib/
├── android/
├── ios/
├── test/
├── assets/
├── pubspec.yaml
└── analysis_options.yaml
```

## Dependencies Installation

### 1. Install Flutter Dependencies
```bash
flutter pub get
```

### 2. Platform-Specific Dependencies

**For iOS (macOS only):**
```bash
cd ios
pod install
cd ..
```

**For Android:**
Dependencies are handled automatically by Gradle.

### 3. Verify Dependencies
Check that all packages are properly installed:
```bash
flutter pub deps
```

## Code Generation

The project uses code generation for various features. Run the following commands:

### 1. Generate Hive Type Adapters
```bash
flutter packages pub run build_runner build
```

### 2. Generate JSON Serialization (if used)
```bash
flutter packages pub run json_annotation
```

### 3. Clean and Rebuild (if needed)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Firebase Configuration

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Follow the setup wizard

### 2. Add Android App
1. Click "Add app" → Android
2. Enter package name: `com.dosify.dosify_flutter`
3. Download `google-services.json`
4. Place in `android/app/`

### 3. Add iOS App (if building for iOS)
1. Click "Add app" → iOS
2. Enter bundle ID: `com.dosify.dosifyFlutter`
3. Download `GoogleService-Info.plist`
4. Add to iOS project in Xcode

### 4. Install Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### 5. Initialize Firebase in Project
```bash
firebase init
```

## Building the App

### 1. Debug Build

**Android:**
```bash
flutter build apk --debug
```

**iOS:**
```bash
flutter build ios --debug
```

### 2. Release Build

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle (Recommended for Play Store):**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

### 3. Build Outputs

**Android:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

**iOS:**
- IPA: Generated through Xcode or `flutter build ipa`

## Testing

### 1. Run Unit Tests
```bash
flutter test
```

### 2. Run Integration Tests
```bash
flutter test integration_test/
```

### 3. Run on Device/Emulator

**List available devices:**
```bash
flutter devices
```

**Run on specific device:**
```bash
flutter run -d <device-id>
```

**Run in release mode:**
```bash
flutter run --release
```

## Deployment

### Android (Google Play Store)

1. **Create Keystore:**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure Signing:**
   Create `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-keystore>
   ```

3. **Build Signed Bundle:**
   ```bash
   flutter build appbundle
   ```

4. **Upload to Play Console**

### iOS (App Store)

1. **Open in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure Signing & Capabilities**

3. **Archive and Upload:**
   - Product → Archive
   - Upload to App Store Connect

## Troubleshooting

### Common Issues

#### 1. "Flutter command not found"
**Solution:** Add Flutter to your PATH
```bash
export PATH="$PATH:`pwd`/flutter/bin"
```

#### 2. "Android SDK not found"
**Solution:** Set ANDROID_HOME environment variable
```bash
export ANDROID_HOME=/path/to/android/sdk
```

#### 3. "CocoaPods not installed" (iOS)
**Solution:**
```bash
sudo gem install cocoapods
pod setup
```

#### 4. "Build failed with an exception"
**Solutions:**
- Clean the project: `flutter clean`
- Get dependencies: `flutter pub get`
- Restart IDE
- Delete `build/` folder and rebuild

#### 5. "Version solving failed"
**Solution:**
```bash
flutter pub upgrade
flutter pub get
```

#### 6. Hive/Local Storage Issues
**Solution:**
```bash
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Platform-Specific Issues

#### Android
- **Gradle build failed:** Update `android/build.gradle` and `android/app/build.gradle`
- **Multidex issues:** Enable multidex in `android/app/build.gradle`

#### iOS
- **Code signing issues:** Check provisioning profiles in Xcode
- **Pod install failed:** Delete `ios/Podfile.lock` and `ios/Pods/`, then run `pod install`

### Performance Optimization

#### 1. App Size Reduction
```bash
flutter build apk --target-platform android-arm,android-arm64 --split-per-abi
```

#### 2. Code Obfuscation
```bash
flutter build apk --obfuscate --split-debug-info=/<project-name>/
```

## Development Workflow

### 1. Hot Reload Development
```bash
flutter run
# Press 'r' for hot reload
# Press 'R' for hot restart
# Press 'q' to quit
```

### 2. Debugging
```bash
flutter run --debug
flutter logs
```

### 3. Code Analysis
```bash
flutter analyze
dart format .
```

### 4. Testing Workflow
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## Build Verification Checklist

Before deploying, ensure:

- [ ] All tests pass: `flutter test`
- [ ] No analysis issues: `flutter analyze`
- [ ] App builds successfully for target platforms
- [ ] Firebase configuration is correct
- [ ] All required permissions are set
- [ ] App icons and splash screens are configured
- [ ] Version numbers are updated in `pubspec.yaml`
- [ ] Release notes are prepared

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Firebase Flutter Setup](https://firebase.flutter.dev/docs/overview)
- [Flutter Deployment Guide](https://flutter.dev/docs/deployment)

## Support

For issues specific to this project:
1. Check this build guide
2. Review the main README.md
3. Check existing GitHub issues
4. Create a new issue with detailed information

---

**Note:** This build guide is specific to the Dosify Flutter medication management app. Ensure all Firebase configurations and package names match your specific implementation.

Last updated: $(Get-Date -Format "yyyy-MM-dd")
