import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Wedding Planner App Typography
/// Primary: Plus Jakarta Sans (headers - modern bold)
/// Secondary: Manrope (body - clean sans-serif)
class AppTypography {
  AppTypography._();

  // Font Families
  static const String fontFamilyPrimary = 'PlusJakartaSans';
  static const String fontFamilySecondary = 'Manrope';

  // Hero Headings (Extra Bold/Black)
  static const TextStyle hero = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  // Heading Styles (Plus Jakarta Sans)
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.015,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // Body Styles (Manrope)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  // Caption/Label Styles (Uppercase tracking)
  static const TextStyle labelOverline = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: AppColors.textTertiary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  static const TextStyle tiny = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textTertiary,
  );

  // Button Text
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  // Special Styles
  static const TextStyle countdown = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -2,
    color: AppColors.textPrimary,
  );

  static const TextStyle countdownUnit = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: AppColors.textTertiary,
  );

  static const TextStyle price = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle tag = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.accent,
  );

  // Compatibility badge
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
}
