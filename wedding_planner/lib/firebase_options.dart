// Firebase configuration for Wedding Planner App
// Generated from google-services.json and GoogleService-Info.plist
// Project: wedding-planner-fcc81

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

  // Web configuration (uses Android API key - add web app in Firebase Console for dedicated key)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBCie08VSS8i48YpaT9-I6X839okxqWOgo',
    appId: '1:22327346735:android:6e84ae465ba1b83cc768da',
    messagingSenderId: '22327346735',
    projectId: 'wedding-planner-fcc81',
    authDomain: 'wedding-planner-fcc81.firebaseapp.com',
    storageBucket: 'wedding-planner-fcc81.firebasestorage.app',
  );

  // Android configuration from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCie08VSS8i48YpaT9-I6X839okxqWOgo',
    appId: '1:22327346735:android:6e84ae465ba1b83cc768da',
    messagingSenderId: '22327346735',
    projectId: 'wedding-planner-fcc81',
    storageBucket: 'wedding-planner-fcc81.firebasestorage.app',
  );

  // iOS configuration from GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQr4Op-jIA7XFfo7ThU4dsJhbX7pinBB0',
    appId: '1:22327346735:ios:32d5af5a5108b85cc768da',
    messagingSenderId: '22327346735',
    projectId: 'wedding-planner-fcc81',
    storageBucket: 'wedding-planner-fcc81.firebasestorage.app',
    iosBundleId: 'com.example.weddingPlanner',
  );

  // macOS configuration (uses iOS config - add macOS app in Firebase Console for dedicated config)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQr4Op-jIA7XFfo7ThU4dsJhbX7pinBB0',
    appId: '1:22327346735:ios:32d5af5a5108b85cc768da',
    messagingSenderId: '22327346735',
    projectId: 'wedding-planner-fcc81',
    storageBucket: 'wedding-planner-fcc81.firebasestorage.app',
    iosBundleId: 'com.example.weddingPlanner',
  );

  // Windows configuration (uses Android config - add web app in Firebase Console for dedicated config)
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBCie08VSS8i48YpaT9-I6X839okxqWOgo',
    appId: '1:22327346735:android:6e84ae465ba1b83cc768da',
    messagingSenderId: '22327346735',
    projectId: 'wedding-planner-fcc81',
    authDomain: 'wedding-planner-fcc81.firebaseapp.com',
    storageBucket: 'wedding-planner-fcc81.firebasestorage.app',
  );
}
