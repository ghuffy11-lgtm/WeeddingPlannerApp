import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

abstract class ChatEvent {
  const ChatEvent();
}

/// Load all conversations
class LoadConversations extends ChatEvent {
  const LoadConversations();
}

/// Conversation list updated from stream
class ConversationsUpdated extends ChatEvent {
  final List<Conversation> conversations;

  const ConversationsUpdated(this.conversations);
}

/// Load messages for a conversation
class LoadMessages extends ChatEvent {
  final String conversationId;

  const LoadMessages(this.conversationId);
}

/// Messages updated from stream
class MessagesUpdated extends ChatEvent {
  final List<Message> messages;

  const MessagesUpdated(this.messages);
}

/// Send a text message
class SendMessage extends ChatEvent {
  final String conversationId;
  final String content;

  const SendMessage({
    required this.conversationId,
    required this.content,
  });
}

/// Send an image message
class SendImageMessage extends ChatEvent {
  final String conversationId;
  final String imagePath;

  const SendImageMessage({
    required this.conversationId,
    required this.imagePath,
  });
}

/// Mark conversation as read
class MarkAsRead extends ChatEvent {
  final String conversationId;

  const MarkAsRead(this.conversationId);
}

/// Set typing status
class SetTyping extends ChatEvent {
  final String conversationId;
  final bool isTyping;

  const SetTyping({
    required this.conversationId,
    required this.isTyping,
  });
}

/// Start a new conversation with a vendor
class StartConversation extends ChatEvent {
  final String vendorId;
  final String vendorName;
  final String? vendorAvatarUrl;
  final String? bookingId;

  const StartConversation({
    required this.vendorId,
    required this.vendorName,
    this.vendorAvatarUrl,
    this.bookingId,
  });
}

/// Delete a conversation
class DeleteConversation extends ChatEvent {
  final String conversationId;

  const DeleteConversation(this.conversationId);
}

/// Clear current conversation
class ClearCurrentConversation extends ChatEvent {
  const ClearCurrentConversation();
}

/// Clear error
class ClearChatError extends ChatEvent {
  const ClearChatError();
}

/// Unread count updated
class UnreadCountUpdated extends ChatEvent {
  final int count;

  const UnreadCountUpdated(this.count);
}
