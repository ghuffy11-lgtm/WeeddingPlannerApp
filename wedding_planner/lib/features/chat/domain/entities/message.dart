import 'package:intl/intl.dart';

/// Represents a chat message
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String? senderName;
  final MessageType type;
  final String content;
  final String? imageUrl;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    required this.type,
    required this.content,
    this.imageUrl,
    required this.status,
    required this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;

  String get timeFormatted => DateFormat('HH:mm').format(createdAt);

  String get dateFormatted {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(createdAt).inDays < 7) {
      return DateFormat('EEEE').format(createdAt);
    } else {
      return DateFormat('MMM d, yyyy').format(createdAt);
    }
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    MessageType? type,
    String? content,
    String? imageUrl,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      type: type ?? this.type,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

enum MessageType {
  text,
  image,
  system;

  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.system:
        return 'System';
    }
  }
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed;

  String get displayName {
    switch (this) {
      case MessageStatus.sending:
        return 'Sending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.failed:
        return 'Failed';
    }
  }
}
