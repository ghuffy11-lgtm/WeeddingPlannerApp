import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Glassmorphism Card Widget
/// Creates a frosted glass effect with blur and semi-transparent background
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final double blurAmount;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.borderColor,
    this.borderWidth = 1,
    this.backgroundColor,
    this.blurAmount = 12,
    this.onTap,
    this.gradient,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null
                ? (backgroundColor ?? AppColors.glassBackground)
                : null,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder,
              width: borderWidth,
            ),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// Glass Button with glassmorphism effect
class GlassButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isPrimary;

  const GlassButton({
    super.key,
    this.onTap,
    required this.child,
    this.width,
    this.height = 48,
    this.borderRadius = 12,
    this.backgroundColor,
    this.borderColor,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppColors.primary
                  : (backgroundColor ?? AppColors.glassBackground),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// Glass Icon Button
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool hasBadge;
  final Color? badgeColor;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
    this.iconColor,
    this.backgroundColor,
    this.hasBadge = false,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: backgroundColor ?? AppColors.glassBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.textPrimary,
                  size: size * 0.5,
                ),
              ),
            ),
          ),
          if (hasBadge)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.backgroundDark,
                    width: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Glass Chip/Tag
class GlassChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const GlassChip({
    super.key,
    required this.label,
    this.color,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: chipColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.white : chipColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isSelected ? AppColors.white : chipColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Background Glow Effect
class BackgroundGlow extends StatelessWidget {
  final Color color;
  final double size;
  final double blur;
  final Alignment alignment;

  const BackgroundGlow({
    super.key,
    required this.color,
    this.size = 300,
    this.blur = 120,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.05),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: blur,
                spreadRadius: blur / 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
