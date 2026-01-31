import 'package:flutter/material.dart';

/// Wedding Planner App Spacing System
/// Based on 4px base unit
class AppSpacing {
  AppSpacing._();

  // Spacing Values
  static const double micro = 4.0;
  static const double small = 8.0;
  static const double base = 16.0;
  static const double medium = 24.0;
  static const double large = 32.0;
  static const double xl = 48.0;
  static const double xxl = 64.0;

  // Corner Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusRound = 50.0;

  // Border Radius
  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(radiusSmall),
  );
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(radiusMedium),
  );
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(radiusLarge),
  );

  // Padding
  static const EdgeInsets paddingAll = EdgeInsets.all(base);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(
    horizontal: base,
  );
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(
    vertical: base,
  );
  static const EdgeInsets paddingCard = EdgeInsets.all(base);

  // Screen Padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: base,
    vertical: medium,
  );

  // Component Heights
  static const double buttonHeight = 56.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 64.0;
  static const double iconButtonSize = 48.0;
  static const double fabSize = 64.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  // Avatar Sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXl = 96.0;
}
