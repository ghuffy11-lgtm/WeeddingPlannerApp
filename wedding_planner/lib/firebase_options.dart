// File generated for Firebase configuration.
// IMPORTANT: Replace these placeholder values with your actual Firebase project configuration.
//
// To get your configuration:
// 1. Go to https://console.firebase.google.com
// 2. Create a new project or select existing one
// 3. Add an Android app with package name: com.example.wedding_planner
// 4. Download google-services.json to android/app/
// 5. Add an iOS app (optional) and download GoogleService-Info.plist
// 6. Update the values below with your Firebase project details
//
// Alternatively, run: dart pub global activate flutterfire_cli
// Then: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // PLACEHOLDER VALUES - Replace with your actual Firebase configuration
  // These are example values and will NOT work until replaced

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'wedding-planner-app',
    authDomain: 'wedding-planner-app.firebaseapp.com',
    storageBucket: 'wedding-planner-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'wedding-planner-app',
    storageBucket: 'wedding-planner-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'wedding-planner-app',
    storageBucket: 'wedding-planner-app.appspot.com',
    iosBundleId: 'com.example.weddingPlanner',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'wedding-planner-app',
    storageBucket: 'wedding-planner-app.appspot.com',
    iosBundleId: 'com.example.weddingPlanner',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'wedding-planner-app',
    authDomain: 'wedding-planner-app.firebaseapp.com',
    storageBucket: 'wedding-planner-app.appspot.com',
  );
}
