# Dosify Flutter

A cross-platform medication management app with scheduling, inventory tracking, and reconstitution calculations.

## Overview

Dosify is a comprehensive medication management application designed for Android and iOS platforms. It focuses on scheduling doses, tracking inventory, and performing reconstitution calculations for injections and peptides.

### Key Features

- **Medication Management**: Add medications and supplies with detailed information
- **Dose Scheduling**: Set reminders with flexible frequency options
- **Inventory Tracking**: Monitor stock levels with low alerts
- **Reconstitution Calculator**: Calculate proper mixing ratios for injections
- **Dose Logging**: Track taken doses with notes and reactions
- **Visual Analytics**: Charts and graphs for adherence tracking
- **Expert Mode**: Advanced statistics and forecasting (toggleable)

### Enhanced Features

- **Multi-Factor Authentication**: Email with phone verification
- **Secure Storage**: Encrypted local data with biometric access
- **Themes**: Dynamic light/dark themes with animations
- **Cloud Sync**: Secure backup and synchronization
- **PDF Reports**: Export medication reports
- **In-App Purchases**: Premium features (cycling, titration, multi-profiles)

## Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: Riverpod
- **Local Database**: Hive (encrypted)
- **Cloud Services**: Firebase (Auth, Firestore, Messaging)
- **Charts**: FL Chart
- **UI**: Material Design with custom themes

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core functionality
│   ├── data/
│   │   ├── models/          # Hive data models
│   │   ├── repositories/    # Data access layer
│   │   ├── hive/           # Hive adapters and boxes
│   │   └── firebase/       # Firebase helpers
│   ├── di/                 # Dependency injection
│   ├── domain/             # Use cases
│   ├── ui/                 # UI components and themes
│   └── utils/              # Utilities and calculators
├── features/               # Feature modules
│   ├── medication/         # Medication management
│   ├── scheduling/         # Dose scheduling
│   ├── inventory/          # Stock tracking
│   ├── reports/            # Analytics and reports
│   ├── auth/               # Authentication
│   ├── settings/           # App settings
│   ├── dashboard/          # Main dashboard
│   └── ...
└── assets/                 # Images and fonts
```

## Setup Instructions

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android SDK (API level 24+)
- Xcode (for iOS development)
- Firebase project (for cloud features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/kinemspa/dosify_flutter.git
   cd dosify_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Firebase Configuration** (Optional for local development)
   - Create a Firebase project
   - Add Android and iOS apps
   - Download and place configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

5. **Run the app**
   ```bash
   flutter run
   ```

### Build Scripts

- **Code Generation**: `./build_runner.sh` or `dart run build_runner build`
- **Debug Build**: `flutter build apk --debug`
- **Release Build**: `flutter build apk --release`

## Data Models

### Core Models

- **Medication**: Medicine information with stock tracking
- **DoseSchedule**: Scheduling information with frequency and timing
- **DoseLog**: Record of taken doses with notes
- **Supply**: Medical supplies and consumables
- **Reconstitution**: Mixing calculations for injections

### IAP Features

- **Cycling**: On/off periods for medications
- **Titration**: Gradual dose adjustments
- **Multi-profiles**: Support for multiple users

## Key Utilities

### Reconstitution Calculator

Calculates proper mixing ratios for injectable medications:

```dart
final result = ReconstitutionCalculator.calculateComplete(
  powderAmount: 10.0,  // mg
  solventVolume: 2.0,  // ml
  desiredDose: 2.5,    // mg
);
```

### Math Utils

Provides calculations for:
- Time until next dose
- Days until expiration
- Doses before refill needed
- Cycle forecasting
- Titration steps

## Architecture

The app follows a modular architecture with:

- **Feature-based modules** for maintainability
- **Riverpod** for state management
- **Repository pattern** for data access
- **Use cases** for business logic
- **Dependency injection** with GetIt

## Testing

- **Unit Tests**: Test utilities and business logic
- **Widget Tests**: Test UI components
- **Integration Tests**: Test complete user flows

Run tests:
```bash
flutter test
```

## Contributing

1. Follow the existing code structure
2. Add tests for new features
3. Run `flutter analyze` before committing
4. Use the build runner for code generation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the GitHub repository.
