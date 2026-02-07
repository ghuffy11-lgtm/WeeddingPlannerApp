# Firebase Setup Guide

This guide explains how to configure Firebase for the Wedding Planner app.

## Current Status

Firebase integration is **COMPLETE** and **CONFIGURED**.

**Project:** `wedding-planner-fcc81`
**Configured:** February 7, 2026

## Files Created/Modified

| File | Purpose |
|------|---------|
| `lib/firebase_options.dart` | Firebase configuration (configured) |
| `lib/main.dart` | Firebase initialization with error handling |
| `android/app/google-services.json` | Android Firebase config (configured) |
| `android/app/build.gradle.kts` | Added Google Services plugin |
| `android/settings.gradle.kts` | Added Google Services plugin dependency |
| `android/app/src/main/AndroidManifest.xml` | Added required permissions |
| `ios/Runner/GoogleService-Info.plist` | iOS Firebase config (configured) |
| `ios/Runner/Info.plist` | Added background modes for notifications |
| `ios/Podfile` | iOS CocoaPods configuration |

## Setup Instructions

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: `wedding-planner-app` (or your preferred name)
4. Enable Google Analytics (optional)
5. Create project

### Step 2: Add Android App

1. In Firebase Console, click "Add app" > Android
2. Enter package name: `com.example.wedding_planner`
3. Enter app nickname: "Wedding Planner Android"
4. Download `google-services.json`
5. Replace `android/app/google-services.json` with the downloaded file

### Step 3: Add iOS App (Optional)

1. In Firebase Console, click "Add app" > iOS
2. Enter bundle ID: `com.example.weddingPlanner`
3. Enter app nickname: "Wedding Planner iOS"
4. Download `GoogleService-Info.plist`
5. Replace `ios/Runner/GoogleService-Info.plist` with the downloaded file

### Step 4: Update firebase_options.dart

After downloading the config files, you have two options:

#### Option A: Use FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (run in wedding_planner directory)
flutterfire configure
```

This will automatically update `lib/firebase_options.dart` with your project values.

#### Option B: Manual Update

Open your downloaded `google-services.json` and update `lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY_FROM_GOOGLE_SERVICES_JSON',
  appId: 'YOUR_GOOGLE_APP_ID',
  messagingSenderId: 'YOUR_PROJECT_NUMBER',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
```

Find these values in google-services.json:
- `apiKey` → `client[0].api_key[0].current_key`
- `appId` → `client[0].client_info.mobilesdk_app_id`
- `messagingSenderId` → `project_info.project_number`
- `projectId` → `project_info.project_id`
- `storageBucket` → `project_info.storage_bucket`

### Step 5: Enable Firebase Services

In Firebase Console, enable the services you need:

1. **Authentication** (for social login)
   - Go to Authentication > Sign-in method
   - Enable Email/Password, Google, Apple

2. **Cloud Firestore** (for chat)
   - Go to Firestore Database
   - Create database in production or test mode

3. **Cloud Messaging** (for push notifications)
   - Automatically enabled with Firebase project

### Step 6: Rebuild the App

```bash
# Clean and rebuild
docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -w /app ghcr.io/cirruslabs/flutter:latest flutter clean

docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -v "flutter_gradle:/root/.gradle" -w /app ghcr.io/cirruslabs/flutter:latest flutter build apk --debug
```

## Verification

After configuration, the app should log:
```
Firebase initialized successfully
```

If you see "Firebase initialization skipped", check your configuration files.

## Firebase Features Used

| Feature | Purpose | Status |
|---------|---------|--------|
| Firebase Core | Base SDK | Ready |
| Firebase Auth | Social login (Google, Apple) | Ready |
| Cloud Firestore | Chat messages storage | Ready |
| Cloud Messaging | Push notifications | Ready |

## Troubleshooting

### "No Firebase App has been created"
- Ensure `google-services.json` is in `android/app/`
- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Verify package name matches exactly

### Build fails with Google Services error
- Check that `google-services.json` has valid JSON format
- Verify the package name in the file matches `com.example.wedding_planner`

### Push notifications not working
- Ensure Cloud Messaging is enabled in Firebase Console
- For iOS, configure APNs in Firebase Console > Project Settings > Cloud Messaging
- Check that `POST_NOTIFICATIONS` permission is granted on Android 13+

## Security Note

The placeholder configuration files (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) contain dummy values. Replace them with your actual Firebase project configuration before deploying to production.

## Related Documentation

- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview)
- [Firebase Console](https://console.firebase.google.com)
- [Cloud Messaging Setup](https://firebase.flutter.dev/docs/messaging/overview)
