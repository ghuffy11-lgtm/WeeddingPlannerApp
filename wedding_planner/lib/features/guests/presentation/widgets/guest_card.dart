import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/guest.dart';

class GuestCard extends StatelessWidget {
  final GuestSummary guest;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool showSelectionCheckbox;

  const GuestCard({
    super.key,
    required this.guest,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.showSelectionCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.zero,
      borderColor: isSelected ? AppColors.primary : null,
      borderWidth: isSelected ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection checkbox or avatar
              if (showSelectionCheckbox)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                )
              else
                _buildAvatar(),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and RSVP status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            guest.fullName,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildRsvpBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Category and side
                    Row(
                      children: [
                        Text(
                          '${guest.category.icon} ${guest.category.displayName}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          guest.side.displayName,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),

                    // Plus ones if any
                    if (guest.plusOnes > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+${guest.plusOnes} guest${guest.plusOnes > 1 ? 's' : ''}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getAvatarColor().withValues(alpha: 0.8),
            _getAvatarColor().withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Center(
        child: Text(
          guest.initials,
          style: AppTypography.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor() {
    switch (guest.side) {
      case GuestSide.bride:
        return AppColors.primary;
      case GuestSide.groom:
        return AppColors.accentPurple;
      case GuestSide.both:
        return AppColors.accent;
    }
  }

  Widget _buildRsvpBadge() {
    Color backgroundColor;
    Color textColor;

    switch (guest.rsvpStatus) {
      case RsvpStatus.confirmed:
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green;
        break;
      case RsvpStatus.declined:
        backgroundColor = Colors.red.withValues(alpha: 0.2);
        textColor = Colors.red;
        break;
      case RsvpStatus.maybe:
        backgroundColor = Colors.orange.withValues(alpha: 0.2);
        textColor = Colors.orange;
        break;
      case RsvpStatus.pending:
        backgroundColor = AppColors.glassBorder;
        textColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        guest.rsvpStatus.displayName,
        style: AppTypography.labelMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Stats card for guest overview
class GuestStatsCard extends StatelessWidget {
  final GuestStats stats;

  const GuestStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guest Overview',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Main stats row
          Row(
            children: [
              _buildStatItem(
                icon: Icons.people_outline,
                label: 'Total',
                value: '${stats.totalGuests}',
                color: AppColors.primary,
              ),
              _buildStatItem(
                icon: Icons.check_circle_outline,
                label: 'Confirmed',
                value: '${stats.confirmedGuests}',
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.groups_outlined,
                label: 'Attending',
                value: '${stats.totalAttending}',
                color: AppColors.accent,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Response rate
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Response Rate',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${stats.confirmationRate.toStringAsFixed(0)}%',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: stats.confirmationRate / 100,
                  backgroundColor: AppColors.glassBorder,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pending responses
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                '${stats.awaitingResponse} awaiting response',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${stats.declinedGuests} declined',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.red.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
