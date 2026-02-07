import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/conversation_tile.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const LoadConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.backgroundDark,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Messages',
                style: AppTypography.h2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.backgroundDark,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // Search button
              IconButton(
                onPressed: () {
                  // TODO: Implement search
                },
                icon: const Icon(Icons.search_rounded),
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state.conversationsStatus == ChatStatus.loading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }

              if (state.conversations.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final conversation = state.conversations[index];
                    return ConversationTile(
                      conversation: conversation,
                      onTap: () {
                        context.push('/chat/${conversation.id}');
                      },
                      onLongPress: () {
                        _showConversationOptions(context, conversation.id);
                      },
                    );
                  },
                  childCount: state.conversations.length,
                ),
              );
            },
          ),

          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.accentPurple.withOpacity(0.2),
                  ],
                ),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No conversations yet',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start chatting with vendors to discuss\nyour wedding plans',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlassButton(
              onTap: () {
                context.go('/vendors');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Browse Vendors',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConversationOptions(BuildContext context, String conversationId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                title: Text(
                  'Delete Conversation',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, conversationId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Conversation?',
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will permanently delete all messages in this conversation.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatBloc>().add(DeleteConversation(conversationId));
            },
            child: Text(
              'Delete',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
