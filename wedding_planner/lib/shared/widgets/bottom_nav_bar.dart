import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Custom Bottom Navigation Bar
/// Matches the design with raised center button
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.9),
        border: const Border(
          top: BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore,
                    label: 'Discover',
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.interpreter_mode_outlined,
                    activeIcon: Icons.interpreter_mode,
                    label: 'Talent',
                    isActive: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _CenterButton(
                    isActive: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    icon: Icons.checklist_outlined,
                    activeIcon: Icons.checklist,
                    label: 'Planner',
                    isActive: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                  _NavItem(
                    icon: Icons.more_horiz,
                    activeIcon: Icons.more_horiz,
                    label: 'Menu',
                    isActive: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            size: 24,
            color: isActive ? AppColors.primary : AppColors.textTertiary,
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AppTypography.tiny.copyWith(
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CenterButton({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -16),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.backgroundDark,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.hub,
                size: 30,
                color: AppColors.white,
              ),
              if (isActive)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accent,
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation item data class
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
