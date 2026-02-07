import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback? onAttachImage;
  final Function(bool)? onTypingChanged;
  final bool isSending;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.onAttachImage,
    this.onTypingChanged,
    this.isSending = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      widget.onTypingChanged?.call(hasText);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;

    widget.onSendMessage(text);
    _controller.clear();
    widget.onTypingChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment button
            if (widget.onAttachImage != null)
              IconButton(
                onPressed: widget.isSending ? null : widget.onAttachImage,
                icon: const Icon(Icons.attach_file_rounded),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),

            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: !widget.isSending,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),

                    // Emoji button (placeholder)
                    IconButton(
                      onPressed: () {
                        // TODO: Show emoji picker
                      },
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      color: AppColors.textTertiary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _hasText && !widget.isSending
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.accentPurple],
                      )
                    : null,
                color: _hasText && !widget.isSending
                    ? null
                    : AppColors.surfaceDark,
              ),
              child: IconButton(
                onPressed: _hasText && !widget.isSending ? _handleSend : null,
                icon: widget.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: _hasText
                            ? Colors.white
                            : AppColors.textTertiary,
                      ),
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
