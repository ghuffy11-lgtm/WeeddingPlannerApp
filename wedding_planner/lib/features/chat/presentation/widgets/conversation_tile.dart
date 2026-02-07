import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/conversation.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and time row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.otherUser.name,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: conversation.hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          conversation.lastMessageTime,
                          style: AppTypography.bodySmall.copyWith(
                            color: conversation.hasUnread
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Last message and unread badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.isTyping
                                ? 'Typing...'
                                : conversation.lastMessagePreview,
                            style: AppTypography.bodySmall.copyWith(
                              color: conversation.isTyping
                                  ? AppColors.accent
                                  : (conversation.hasUnread
                                      ? AppColors.textSecondary
                                      : AppColors.textTertiary),
                              fontStyle: conversation.isTyping
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.hasUnread) ...[
                          const SizedBox(width: 8),
                          _buildUnreadBadge(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.accentPurple.withOpacity(0.8),
              ],
            ),
          ),
          child: conversation.otherUser.avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    conversation.otherUser.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitials(),
                  ),
                )
              : _buildInitials(),
        ),

        // Online indicator
        if (conversation.otherUser.isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceDark,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        conversation.otherUser.initials,
        style: AppTypography.h4.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        conversation.unreadCount > 99 ? '99+' : '${conversation.unreadCount}',
        style: AppTypography.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
