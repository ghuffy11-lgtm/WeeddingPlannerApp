import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

enum ChatStatus {
  initial,
  loading,
  loaded,
  error,
}

enum MessagesLoadStatus {
  initial,
  loading,
  loaded,
  sending,
  error,
}

class ChatState {
  final ChatStatus conversationsStatus;
  final List<Conversation> conversations;
  final String? conversationsError;

  final MessagesLoadStatus messagesStatus;
  final String? currentConversationId;
  final Conversation? currentConversation;
  final List<Message> messages;
  final String? messagesError;

  final bool isSending;
  final String? sendError;

  final int totalUnreadCount;

  const ChatState({
    this.conversationsStatus = ChatStatus.initial,
    this.conversations = const [],
    this.conversationsError,
    this.messagesStatus = MessagesLoadStatus.initial,
    this.currentConversationId,
    this.currentConversation,
    this.messages = const [],
    this.messagesError,
    this.isSending = false,
    this.sendError,
    this.totalUnreadCount = 0,
  });

  ChatState copyWith({
    ChatStatus? conversationsStatus,
    List<Conversation>? conversations,
    String? conversationsError,
    bool clearConversationsError = false,
    MessagesLoadStatus? messagesStatus,
    String? currentConversationId,
    bool clearCurrentConversation = false,
    Conversation? currentConversation,
    List<Message>? messages,
    String? messagesError,
    bool clearMessagesError = false,
    bool? isSending,
    String? sendError,
    bool clearSendError = false,
    int? totalUnreadCount,
  }) {
    return ChatState(
      conversationsStatus: conversationsStatus ?? this.conversationsStatus,
      conversations: conversations ?? this.conversations,
      conversationsError: clearConversationsError
          ? null
          : (conversationsError ?? this.conversationsError),
      messagesStatus: messagesStatus ?? this.messagesStatus,
      currentConversationId: clearCurrentConversation
          ? null
          : (currentConversationId ?? this.currentConversationId),
      currentConversation: clearCurrentConversation
          ? null
          : (currentConversation ?? this.currentConversation),
      messages: clearCurrentConversation ? [] : (messages ?? this.messages),
      messagesError:
          clearMessagesError ? null : (messagesError ?? this.messagesError),
      isSending: isSending ?? this.isSending,
      sendError: clearSendError ? null : (sendError ?? this.sendError),
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
    );
  }

  /// Get conversation by ID
  Conversation? getConversation(String id) {
    try {
      return conversations.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
