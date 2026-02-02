import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Elegant Countdown Card Widget
/// Premium design with glassmorphism and decorative elements
class CountdownCard extends StatefulWidget {
  final int? daysUntilWedding;
  final String coupleNames;
  final DateTime? weddingDate;
  final VoidCallback? onTap;

  const CountdownCard({
    super.key,
    this.daysUntilWedding,
    required this.coupleNames,
    this.weddingDate,
    this.onTap,
  });

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.roseGold.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD4A5A5), // Soft dusty rose
                      AppColors.roseGold,
                      Color(0xFFB8860B), // Dark golden rod
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Decorative pattern overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: _FloralPatternPainter(),
                ),
              ),

              // Shimmer effect
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(_shimmerAnimation.value - 1, 0),
                          end: Alignment(_shimmerAnimation.value, 0),
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Glass card overlay
              Positioned(
                left: 20,
                right: 20,
                top: 30,
                bottom: 30,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.large),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Decorative flourish
                          _buildFlourish(),
                          const SizedBox(height: AppSpacing.small),

                          // Couple names with elegant typography
                          Text(
                            widget.coupleNames,
                            style: AppTypography.h2.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.base),

                          // Countdown or set date prompt
                          if (widget.daysUntilWedding != null) ...[
                            _buildElegantCountdown(),
                          ] else ...[
                            _buildSetDatePrompt(),
                          ],

                          // Wedding date with elegant styling
                          if (widget.weddingDate != null) ...[
                            const SizedBox(height: AppSpacing.base),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.base,
                                vertical: AppSpacing.small,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatDate(widget.weddingDate!),
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.small),
                          // Bottom flourish
                          _buildFlourish(flip: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Corner decorations
              Positioned(
                top: 10,
                left: 10,
                child: _buildCornerDecoration(),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Transform.scale(
                  scaleX: -1,
                  child: _buildCornerDecoration(),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Transform.scale(
                  scaleY: -1,
                  child: _buildCornerDecoration(),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Transform.scale(
                  scaleX: -1,
                  scaleY: -1,
                  child: _buildCornerDecoration(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElegantCountdown() {
    final days = widget.daysUntilWedding!;
    final isToday = days == 0;
    final isPast = days < 0;

    if (isToday) {
      return Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFFFD700)],
            ).createShader(bounds),
            child: Text(
              "Today!",
              style: AppTypography.h1.copyWith(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ),
          Text(
            "Your dream becomes reality",
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Days number with elegant styling
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPast ? "${days.abs()}" : "$days",
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w200,
                color: AppColors.white,
                height: 1,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isPast ? "days of beautiful memories" : "days until forever begins",
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontStyle: FontStyle.italic,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSetDatePrompt() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.favorite_outline,
            color: AppColors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          "Set your special date",
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          "Tap to begin the countdown",
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFlourish({bool flip = false}) {
    return Transform.scale(
      scaleY: flip ? -1 : 1,
      child: SizedBox(
        width: 100,
        height: 15,
        child: CustomPaint(
          painter: _FlourishPainter(),
        ),
      ),
    );
  }

  Widget _buildCornerDecoration() {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _CornerPainter(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Flourish decoration painter
class _FlourishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();

    // Center line
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width * 0.3, size.height / 2);

    // Left curl
    path.moveTo(size.width * 0.3, size.height / 2);
    path.quadraticBezierTo(
      size.width * 0.35, size.height * 0.2,
      size.width * 0.4, size.height / 2,
    );

    // Center diamond
    path.moveTo(size.width * 0.45, size.height / 2);
    path.lineTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.55, size.height / 2);
    path.lineTo(size.width * 0.5, size.height * 0.8);
    path.close();

    // Right curl
    path.moveTo(size.width * 0.6, size.height / 2);
    path.quadraticBezierTo(
      size.width * 0.65, size.height * 0.2,
      size.width * 0.7, size.height / 2,
    );

    // Right line
    path.moveTo(size.width * 0.7, size.height / 2);
    path.lineTo(size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Corner decoration painter
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(0, 0);
    path.lineTo(size.width * 0.7, 0);

    // Small curl
    path.moveTo(size.width * 0.3, 0);
    path.quadraticBezierTo(
      size.width * 0.15, size.height * 0.15,
      0, size.height * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Subtle floral pattern painter
class _FloralPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw subtle decorative circles
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 8; j++) {
        final x = (size.width / 5) * i + (size.width / 10);
        final y = (size.height / 8) * j + (size.height / 16);

        canvas.drawCircle(Offset(x, y), 20, paint);

        // Small inner detail
        canvas.drawCircle(Offset(x, y), 8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
