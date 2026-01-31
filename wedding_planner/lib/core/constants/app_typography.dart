import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Wedding Planner App Typography
/// Primary: Cormorant Garamond (headers - elegant serif)
/// Secondary: Inter (body - clean sans-serif)
class AppTypography {
  AppTypography._();

  // Font Families
  static const String fontFamilyPrimary = 'CormorantGaramond';
  static const String fontFamilySecondary = 'Inter';

  // Heading Styles (Cormorant Garamond)
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.deepCharcoal,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.deepCharcoal,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.deepCharcoal,
  );

  // Body Styles (Inter)
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

  // Caption Styles
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  static const TextStyle tiny = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  // Button Text
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  // Special Styles
  static const TextStyle countdown = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.deepCharcoal,
  );

  static const TextStyle price = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.deepCharcoal,
  );
}
