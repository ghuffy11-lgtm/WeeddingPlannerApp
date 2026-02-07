import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showTime;
  final bool showStatus;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showTime = true,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.system) {
      return _buildSystemMessage();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 64 : 16,
        right: isMe ? 16 : 64,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primary.withOpacity(0.9)
                  : AppColors.surfaceDark,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              border: isMe
                  ? null
                  : Border.all(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.image && message.imageUrl != null)
                  _buildImageContent(),
                if (message.type == MessageType.text ||
                    (message.type == MessageType.image &&
                        message.content.isNotEmpty))
                  Text(
                    message.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),

          // Time and status
          if (showTime || (showStatus && isMe))
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showTime)
                    Text(
                      message.timeFormatted,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  if (showStatus && isMe) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          message.imageUrl!,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 200,
              height: 200,
              color: AppColors.surfaceDark,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            width: 200,
            height: 200,
            color: AppColors.surfaceDark,
            child: const Icon(
              Icons.broken_image_outlined,
              color: AppColors.textTertiary,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = AppColors.textTertiary;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = AppColors.textTertiary;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = AppColors.textTertiary;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = AppColors.accent;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Icon(icon, size: 14, color: color);
  }

  Widget _buildSystemMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class DateSeparator extends StatelessWidget {
  final String date;

  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            date,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
