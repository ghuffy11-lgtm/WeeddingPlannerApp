import 'package:flutter/material.dart';

/// Wedding Planner App Color Palette
/// Dark theme with hot pink, cyan, and purple accents
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFEE2B7C); // Hot pink
  static const Color primaryLight = Color(0xFFFF5277);
  static const Color primaryDark = Color(0xFFB91D5E);

  // Accent Colors
  static const Color accent = Color(0xFF00F2FF); // Cyan
  static const Color accentPurple = Color(0xFF7000FF);
  static const Color accentPink = Color(0xFFEE2B7C);
  static const Color accentCyan = Color(0xFF00F2FF);

  // Background Colors (Dark Theme)
  static const Color backgroundDark = Color(0xFF0A0A0C);
  static const Color surfaceDark = Color(0xFF16161A);
  static const Color hubBg = Color(0xFF050508);
  static const Color cardDark = Color(0xFF1A1A2E);

  // Legacy support
  static const Color background = backgroundDark;
  static const Color cardBackground = surfaceDark;

  // Glass Effect Colors
  static const Color glassBackground = Color(0x0AFFFFFF); // 4% white
  static const Color glassBorder = Color(0x1AFFFFFF); // 10% white
  static const Color glassBackgroundLight = Color(0x08FFFFFF); // 3% white

  // Functional Colors
  static const Color success = Color(0xFF4ADE80); // Green
  static const Color warning = Color(0xFFFBBF24); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color pending = Color(0xFFA78BFA); // Purple

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color divider = Color(0x14FFFFFF); // 8% white

  // Text Colors
  static const Color textPrimary = white;
  static const Color textSecondary = Color(0x99FFFFFF); // 60% white
  static const Color textTertiary = Color(0x66FFFFFF); // 40% white
  static const Color textLight = Color(0x4DFFFFFF); // 30% white
  static const Color textOnPrimary = white;

  // Legacy colors for backwards compatibility
  static const Color blushRose = primary;
  static const Color softIvory = surfaceDark;
  static const Color champagne = primaryLight;
  static const Color roseGold = primary;
  static const Color sageGreen = success;
  static const Color dustyBlue = accent;
  static const Color warmGray = textSecondary;
  static const Color deepCharcoal = backgroundDark;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryLight, primary],
  );

  static const LinearGradient mastermindGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient countdownGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPurple, accentCyan],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF0A0A0C)],
  );

  // Shadow Colors
  static const Color primaryShadow = Color(0x66FF2D55); // 40% primary
  static const Color cyanGlow = Color(0x4D00F2FF); // 30% cyan
  static const Color purpleGlow = Color(0x337000FF); // 20% purple
}
