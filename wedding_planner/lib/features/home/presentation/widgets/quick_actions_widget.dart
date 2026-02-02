import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Quick Action Item
class QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

/// Quick Actions Widget
/// Grid of quick action buttons for common tasks
class QuickActionsWidget extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsWidget({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.h3.copyWith(
            color: AppColors.deepCharcoal,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: AppSpacing.small,
            crossAxisSpacing: AppSpacing.small,
            childAspectRatio: 0.9,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _QuickActionButton(action: actions[index]);
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final color = action.color ?? AppColors.roseGold;

    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              action.icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.micro),
          Text(
            action.label,
            style: AppTypography.tiny.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
