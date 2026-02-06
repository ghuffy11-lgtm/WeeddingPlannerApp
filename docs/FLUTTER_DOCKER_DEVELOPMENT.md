# Flutter Development with Docker

This document explains how to run Flutter commands without installing Flutter locally. Use Docker with the official Flutter image.

## Prerequisites

- Docker must be installed and running
- No Flutter installation required on host machine

## Docker Image

Use the Cirrus CI Flutter image which includes Flutter SDK and Android SDK:

```
ghcr.io/cirruslabs/flutter:latest
```

## Volume Mounts (Important for Performance)

Always use these volume mounts to cache dependencies between runs:

| Mount | Purpose |
|-------|---------|
| `$(pwd):/app` | Project directory |
| `flutter_pub_cache:/root/.pub-cache` | Dart/Flutter packages cache |
| `flutter_gradle:/root/.gradle` | Gradle cache (Android builds) |

## Common Commands

### Get Dependencies
```bash
cd /mnt/repo/WeeddingPlannerApp/wedding_planner
docker run --rm \
  -v "$(pwd)":/app \
  -v "flutter_pub_cache:/root/.pub-cache" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  flutter pub get
```

### Analyze Code (Check for Errors)
```bash
docker run --rm \
  -v "$(pwd)":/app \
  -v "flutter_pub_cache:/root/.pub-cache" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  flutter analyze
```

### Build Android Debug APK
```bash
docker run --rm \
  -v "$(pwd)":/app \
  -v "flutter_pub_cache:/root/.pub-cache" \
  -v "flutter_gradle:/root/.gradle" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Build Android Release APK
```bash
docker run --rm \
  -v "$(pwd)":/app \
  -v "flutter_pub_cache:/root/.pub-cache" \
  -v "flutter_gradle:/root/.gradle" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  flutter build apk --release
```

### Build with Custom API URL
```bash
docker run --rm \
  -v "$(pwd)":/app \
  -v "flutter_pub_cache:/root/.pub-cache" \
  -v "flutter_gradle:/root/.gradle" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  flutter build apk --debug --dart-define=API_BASE_URL=http://10.1.13.98:3000/api/v1
```

### Run Tests
```bash
docker run --rm \
  -v "$(pwd)":/app \
  -v "flutter_pub_cache:/root/.pub-cache" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  flutter test
```

### Generate Code (build_runner)
```bash
docker run --rm \
  -v "$(pwd)":/app \
  -v "flutter_pub_cache:/root/.pub-cache" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean Build
```bash
docker run --rm \
  -v "$(pwd)":/app \
  -v "flutter_pub_cache:/root/.pub-cache" \
  -v "flutter_gradle:/root/.gradle" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  flutter clean
```

### Check Flutter Version
```bash
docker run --rm ghcr.io/cirruslabs/flutter:latest flutter --version
```

## One-Liner for Quick Build

Copy-paste this to build a debug APK:

```bash
cd /mnt/repo/WeeddingPlannerApp/wedding_planner && docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -v "flutter_gradle:/root/.gradle" -w /app ghcr.io/cirruslabs/flutter:latest flutter build apk --debug
```

## Troubleshooting

### First Run is Slow
The first build downloads Android SDK components and dependencies. Subsequent builds use cached volumes and are much faster.

### "No such file or directory" Errors
Make sure you're running from the correct directory (`/mnt/repo/WeeddingPlannerApp/wedding_planner`).

### Gradle Memory Issues
Add memory flags if builds fail:
```bash
docker run --rm \
  -v "$(pwd)":/app \
  -v "flutter_pub_cache:/root/.pub-cache" \
  -v "flutter_gradle:/root/.gradle" \
  -e "GRADLE_OPTS=-Xmx4g" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  flutter build apk --debug
```

### Clear All Caches
```bash
docker volume rm flutter_pub_cache flutter_gradle
```

## Build Outputs

| Build Type | Output Path |
|------------|-------------|
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk` |
| Release APK | `build/app/outputs/flutter-apk/app-release.apk` |
| App Bundle | `build/app/outputs/bundle/release/app-release.aab` |

## Notes for AI Agents

1. **Always use Docker** - Flutter is not installed on the host machine
2. **Always include volume mounts** - This caches dependencies and speeds up builds
3. **Working directory** - Must be `/mnt/repo/WeeddingPlannerApp/wedding_planner`
4. **Timeout** - APK builds can take 5-10 minutes on first run, set timeout to 600000ms
5. **Web builds** - May have issues with Docker pub cache; prefer APK builds for testing
