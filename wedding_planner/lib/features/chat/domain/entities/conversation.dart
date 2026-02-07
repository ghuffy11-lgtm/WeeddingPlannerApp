import 'package:intl/intl.dart';
import 'chat_user.dart';
import 'message.dart';

/// Represents a conversation between couple and vendor
class Conversation {
  final String id;
  final ChatUser otherUser;
  final String? bookingId;
  final Message? lastMessage;
  final int unreadCount;
  final bool isTyping;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.otherUser,
    this.bookingId,
    this.lastMessage,
    this.unreadCount = 0,
    this.isTyping = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasUnread => unreadCount > 0;

  String get lastMessagePreview {
    if (lastMessage == null) return 'No messages yet';

    if (isTyping) return 'Typing...';

    switch (lastMessage!.type) {
      case MessageType.text:
        return lastMessage!.content;
      case MessageType.image:
        return 'Sent an image';
      case MessageType.system:
        return lastMessage!.content;
    }
  }

  String get lastMessageTime {
    if (lastMessage == null) return '';

    final now = DateTime.now();
    final messageTime = lastMessage!.createdAt;
    final diff = now.difference(messageTime);

    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return DateFormat('EEE').format(messageTime);
    return DateFormat('MMM d').format(messageTime);
  }

  Conversation copyWith({
    String? id,
    ChatUser? otherUser,
    String? bookingId,
    Message? lastMessage,
    int? unreadCount,
    bool? isTyping,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      otherUser: otherUser ?? this.otherUser,
      bookingId: bookingId ?? this.bookingId,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isTyping: isTyping ?? this.isTyping,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
