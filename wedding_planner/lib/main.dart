import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'config/injection.dart';
import 'firebase_options.dart';

/// Global flag to check if Firebase is available
bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Firebase will be available once you:
  // 1. Create a Firebase project at https://console.firebase.google.com
  // 2. Add your app and download google-services.json to android/app/
  // 3. Update lib/firebase_options.dart with your project values
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    isFirebaseInitialized = false;
    debugPrint('Firebase initialization skipped: $e');
    debugPrint('The app will continue without Firebase features (chat, push notifications).');
    debugPrint('To enable Firebase, configure your project and update firebase_options.dart');
  }

  // Initialize Hive for local storage (not supported on web)
  if (!kIsWeb) {
    await Hive.initFlutter();
  }

  // Setup dependency injection
  await configureDependencies();

  // Set preferred orientations (not supported on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style for dark theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0A0C),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  runApp(const WeddingPlannerApp());
}
