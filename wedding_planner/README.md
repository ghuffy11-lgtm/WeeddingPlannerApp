# Wedding Planner App

A comprehensive wedding planning and vendor marketplace mobile application built with Flutter.

## Getting Started

### Prerequisites

- Flutter SDK 3.16+
- Dart 3.2+
- Android Studio / VS Code
- Xcode (for iOS development)
- Firebase CLI

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code (freezed, json_serializable, etc.):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # MaterialApp configuration
├── core/                  # Core utilities & constants
│   ├── constants/         # Colors, typography, spacing
│   ├── theme/             # App themes
│   ├── errors/            # Failures & exceptions
│   └── network/           # API client & interceptors
├── config/                # App configuration
│   ├── routes.dart        # Navigation routes
│   └── injection.dart     # Dependency injection
├── l10n/                  # Localization (EN, AR)
├── features/              # Feature modules (Clean Architecture)
│   ├── auth/
│   ├── home/
│   ├── vendors/
│   ├── tasks/
│   ├── budget/
│   ├── guests/
│   ├── invitations/
│   ├── chat/
│   └── profile/
└── shared/                # Shared widgets & components
    ├── widgets/
    └── animations/
```

## Architecture

This project follows **Clean Architecture** with the **BLoC pattern** for state management:

- **Domain Layer**: Entities, Repository interfaces, Use cases
- **Data Layer**: Data sources (remote/local), Models, Repository implementations
- **Presentation Layer**: BLoCs, Pages, Widgets

## Features

### MVP (Phase 1)
- User authentication (email, social)
- Wedding setup & onboarding
- Home dashboard with countdown
- Vendor browsing & booking
- Task checklist
- Guest list management
- Budget tracker
- Invitations & RSVP
- Chat with vendors

### Phase 2
- Payment processing
- Smart task generation
- Calendar integration
- Vendor comparison

### Phase 2.5
- 2D venue layout designer

### Phase 3
- AR venue visualization
- Smart seating algorithm
- Video invitations

## Design System

The app uses a custom design system based on the "Calm Clarity in Chaos" philosophy:

- **Primary Colors**: Blush Rose, Soft Ivory, Champagne, Rose Gold
- **Typography**: Cormorant Garamond (headers), Inter (body)
- **Spacing**: 4px base unit system

## Localization

The app supports:
- English (en)
- Arabic (ar) with RTL support

## Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test
```

## Building for Production

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Environment Configuration

Create a `.env` file in the root directory with:

```env
API_BASE_URL=https://api.weddingplanner.app/v1
FIREBASE_PROJECT_ID=your-project-id
GOOGLE_MAPS_API_KEY=your-api-key
STRIPE_PUBLISHABLE_KEY=your-stripe-key
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests and linting
4. Submit a pull request

## License

Proprietary - All rights reserved
