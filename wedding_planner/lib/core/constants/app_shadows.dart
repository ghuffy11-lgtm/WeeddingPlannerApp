import 'package:flutter/material.dart';

/// Wedding Planner App Elevation/Shadow System
class AppShadows {
  AppShadows._();

  // Level 1: Cards
  static List<BoxShadow> get level1 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];

  // Level 2: Raised Cards
  static List<BoxShadow> get level2 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: const Offset(0, 4),
          blurRadius: 16,
        ),
      ];

  // Level 3: Modals
  static List<BoxShadow> get level3 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          offset: const Offset(0, 8),
          blurRadius: 24,
        ),
      ];

  // Level 4: AR Overlay
  static List<BoxShadow> get level4 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.16),
          offset: const Offset(0, 16),
          blurRadius: 48,
        ),
      ];
}
