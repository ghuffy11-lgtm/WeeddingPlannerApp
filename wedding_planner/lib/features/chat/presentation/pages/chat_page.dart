import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;

  const ChatPage({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadMessages(widget.conversationId));
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    // Get current user ID from auth
    // For now, we'll get it from the chat bloc's data source
    // In a real app, you'd get this from your auth service
    setState(() {
      _currentUserId = 'current_user'; // Placeholder
    });
  }

  @override
  void dispose() {
    context.read<ChatBloc>().add(const ClearCurrentConversation());
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listenWhen: (previous, current) =>
                  previous.messages.length != current.messages.length,
              listener: (context, state) {
                // Scroll to bottom when new message arrives
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              },
              builder: (context, state) {
                if (state.messagesStatus == MessagesLoadStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state.messages.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildMessagesList(state.messages, state);
              },
            ),
          ),

          // Input
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return ChatInput(
                onSendMessage: (content) {
                  context.read<ChatBloc>().add(SendMessage(
                        conversationId: widget.conversationId,
                        content: content,
                      ));
                },
                onAttachImage: () {
                  // TODO: Implement image picker
                },
                onTypingChanged: (isTyping) {
                  context.read<ChatBloc>().add(SetTyping(
                        conversationId: widget.conversationId,
                        isTyping: isTyping,
                      ));
                },
                isSending: state.isSending,
              );
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surfaceDark,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: AppColors.textPrimary,
      ),
      title: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final conversation = state.currentConversation;
          if (conversation == null) {
            return const SizedBox();
          }

          return Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
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
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              conversation.otherUser.initials,
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          conversation.otherUser.initials,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.otherUser.name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      conversation.isTyping
                          ? 'Typing...'
                          : (conversation.otherUser.isOnline
                              ? 'Online'
                              : conversation.otherUser.lastSeenText),
                      style: AppTypography.caption.copyWith(
                        color: conversation.isTyping || conversation.otherUser.isOnline
                            ? AppColors.accent
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Show call options
          },
          icon: const Icon(Icons.phone_outlined),
          color: AppColors.textSecondary,
        ),
        IconButton(
          onPressed: () {
            // TODO: Show more options
          },
          icon: const Icon(Icons.more_vert_rounded),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final conversation = state.currentConversation;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
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
                  child: conversation?.otherUser.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            conversation!.otherUser.avatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            conversation?.otherUser.initials ?? '?',
                            style: AppTypography.h2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  conversation?.otherUser.name ?? 'Vendor',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Send a message to start the conversation',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessagesList(List<Message> messages, ChatState state) {
    // Group messages by date
    final groupedMessages = <String, List<Message>>{};
    for (final message in messages) {
      final date = message.dateFormatted;
      groupedMessages.putIfAbsent(date, () => []);
      groupedMessages[date]!.add(message);
    }

    // Build list items
    final items = <Widget>[];
    groupedMessages.forEach((date, dateMessages) {
      items.add(DateSeparator(date: date));
      for (int i = 0; i < dateMessages.length; i++) {
        final message = dateMessages[i];
        final isMe = _isMyMessage(message, state);
        items.add(MessageBubble(
          message: message,
          isMe: isMe,
          showTime: true,
          showStatus: isMe,
        ));
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  bool _isMyMessage(Message message, ChatState state) {
    // Compare sender ID with current user
    // In a real app, you'd compare with the authenticated user's ID
    final currentConversation = state.currentConversation;
    if (currentConversation == null) return false;

    // If sender is not the other user, it's our message
    return message.senderId != currentConversation.otherUser.id;
  }
}
