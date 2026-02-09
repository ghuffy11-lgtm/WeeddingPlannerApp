# Instructions for AI Agents

Quick reference for AI agents working on this project.

## Project Structure

```
WeeddingPlannerApp/
├── wedding_planner/          # Flutter mobile app
├── backend/                  # Node.js/Express API
├── docs/                     # Documentation
├── design_references/        # UI design files from Google Stitch
└── database/                 # SQL init scripts
```

## Flutter App Location

```
/mnt/repo/WeeddingPlannerApp/wedding_planner
```

## Building Flutter (IMPORTANT)

**Flutter is NOT installed locally. Use Docker:**

```bash
cd /mnt/repo/WeeddingPlannerApp/wedding_planner

# Get dependencies
docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -w /app ghcr.io/cirruslabs/flutter:latest flutter pub get

# Analyze code (check for errors)
docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -w /app ghcr.io/cirruslabs/flutter:latest flutter analyze

# Build Release APK (recommended for user testing)
docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -v "flutter_gradle:/root/.gradle" -w /app ghcr.io/cirruslabs/flutter:latest flutter build apk --release

# Build Debug APK (for development)
docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -v "flutter_gradle:/root/.gradle" -w /app ghcr.io/cirruslabs/flutter:latest flutter build apk --debug
```

**Output (Release):** `build/app/outputs/flutter-apk/app-release.apk` (~60MB)
**Output (Debug):** `build/app/outputs/flutter-apk/app-debug.apk` (~150MB)

**Timeout:** Set to 600000ms (10 min) for APK builds.

See [docs/FLUTTER_DOCKER_DEVELOPMENT.md](./docs/FLUTTER_DOCKER_DEVELOPMENT.md) for more commands.

## Design System

The app uses a **dark theme** with these colors:

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#EE2B7C` | Hot pink, main accent |
| Accent Cyan | `#00F2FF` | Secondary accent |
| Accent Purple | `#7000FF` | Tertiary accent, glows |
| Background Dark | `#0A0A0C` | Main background |
| Surface Dark | `#16161A` | Card backgrounds |

Design reference files are in `/design_references/wedapp/`.

## Key Files

| Purpose | File |
|---------|------|
| Colors | `lib/core/constants/app_colors.dart` |
| Typography | `lib/core/constants/app_typography.dart` |
| Theme | `lib/core/theme/app_theme.dart` |
| Glass widgets | `lib/shared/widgets/glass_card.dart` |
| Routes | `lib/config/routes.dart` |
| DI | `lib/config/injection.dart` |

## User Preferences

- User wants to control design decisions
- Show designs for approval before major changes
- User prefers dark, elegant, "fancy" designs (not simple webpage-like)
- User downloaded design from Google Stitch that they like

## User Testing Setup

- **Device**: Tablet
- **APK Type**: Release APK (smaller, faster)
- **APK Location**: `wedding_planner/build/app/outputs/flutter-apk/app-release.apk`
- **IMPORTANT**: User must **uninstall old APK before installing new one** - signature conflicts cause "App not installed as package conflicts with existing package" error
- **Build command**: `flutter build apk --release` (via Docker)

## Session History

- **Session 1-2:** Initial project setup, backend, Flutter structure
- **Session 3:** Design overhaul to dark theme with glassmorphism
- **Session 4:** Firebase integration, Chat system
- **Session 5:** Guest Management, Budget Tracker
- **Session 6:** Task Management (current)

## Features Implemented

| Feature | Status | Files |
|---------|--------|-------|
| Auth (Login/Register) | ✅ Complete | `lib/features/auth/` |
| Onboarding (6 steps) | ✅ Complete | `lib/features/onboarding/` |
| Home Dashboard | ✅ Complete | `lib/features/home/` |
| Vendor Marketplace | ✅ Complete | `lib/features/vendors/` |
| Booking System | ✅ Complete | `lib/features/booking/` |
| Chat (Firebase) | ✅ Complete | `lib/features/chat/` |
| Guest Management | ✅ Complete | `lib/features/guests/` |
| Budget Tracker | ✅ Complete | `lib/features/budget/` |
| Task Management | ✅ Complete | `lib/features/tasks/` |
| Profile/Settings | ❌ Not Started | - |
| Invitations | ❌ Not Started | - |

See [PROJECT_MANAGEMENT/SESSION_LOG.md](./PROJECT_MANAGEMENT/SESSION_LOG.md) for detailed logs.

## Backend

The backend API runs on the user's server at `10.1.13.98:3000`.

To build for physical device testing, use:
```bash
docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -v "flutter_gradle:/root/.gradle" -w /app ghcr.io/cirruslabs/flutter:latest flutter build apk --debug --dart-define=API_BASE_URL=http://10.1.13.98:3000/api/v1
```
