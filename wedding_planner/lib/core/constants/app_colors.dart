import 'package:flutter/material.dart';

/// Wedding Planner App Color Palette
/// Based on "Calm Clarity in Chaos" design philosophy
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color blushRose = Color(0xFFF4E4E1);
  static const Color softIvory = Color(0xFFFEFAF7);
  static const Color champagne = Color(0xFFE8D5C4);
  static const Color roseGold = Color(0xFFD4A59A);

  // Secondary Colors
  static const Color sageGreen = Color(0xFFA7BAA3);
  static const Color dustyBlue = Color(0xFFB4C5D8);
  static const Color warmGray = Color(0xFF6B6B6B);
  static const Color deepCharcoal = Color(0xFF2C2C2C);

  // Functional Colors
  static const Color success = Color(0xFF7BAF6F);
  static const Color warning = Color(0xFFE8B563);
  static const Color error = Color(0xFFD78A8A);
  static const Color pending = Color(0xFFC5A8D0);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = blushRose;
  static const Color cardBackground = softIvory;
  static const Color divider = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textPrimary = deepCharcoal;
  static const Color textSecondary = warmGray;
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textOnPrimary = white;

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [roseGold, champagne],
  );

  static const LinearGradient countdownGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8D5C4), Color(0xFFD4A59A)],
  );
}
