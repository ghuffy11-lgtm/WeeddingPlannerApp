import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/chat_user.dart';
import '../../domain/entities/message.dart';
import 'chat_user_model.dart';
import 'message_model.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.otherUser,
    super.bookingId,
    super.lastMessage,
    super.unreadCount,
    super.isTyping,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConversationModel.fromFirestore(
    DocumentSnapshot doc, {
    required String currentUserId,
  }) {
    final json = doc.data() as Map<String, dynamic>;

    // Determine which user is "other" based on current user
    final participants = json['participants'] as List<dynamic>? ?? [];
    final participantDetails =
        json['participantDetails'] as Map<String, dynamic>? ?? {};

    // Find the other user's ID
    String? otherUserId;
    for (final p in participants) {
      if (p != currentUserId) {
        otherUserId = p as String;
        break;
      }
    }

    // Get other user details
    ChatUser otherUser;
    if (otherUserId != null && participantDetails.containsKey(otherUserId)) {
      final otherUserData = participantDetails[otherUserId] as Map<String, dynamic>;
      otherUser = ChatUserModel.fromFirestore({
        'id': otherUserId,
        ...otherUserData,
      });
    } else {
      otherUser = ChatUser(
        id: otherUserId ?? 'unknown',
        name: 'Unknown User',
        type: ChatUserType.vendor,
      );
    }

    // Parse last message if exists
    Message? lastMessage;
    if (json['lastMessage'] != null) {
      final lm = json['lastMessage'] as Map<String, dynamic>;
      lastMessage = Message(
        id: lm['id'] as String? ?? '',
        conversationId: doc.id,
        senderId: lm['senderId'] as String? ?? '',
        senderName: lm['senderName'] as String?,
        type: MessageType.values.firstWhere(
          (e) => e.name == lm['type'],
          orElse: () => MessageType.text,
        ),
        content: lm['content'] as String? ?? '',
        imageUrl: lm['imageUrl'] as String?,
        status: MessageStatus.sent,
        createdAt: lm['createdAt'] != null
            ? (lm['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    }

    // Get unread count for current user
    final unreadCounts = json['unreadCounts'] as Map<String, dynamic>? ?? {};
    final unreadCount = unreadCounts[currentUserId] as int? ?? 0;

    // Check typing status
    final typingUsers = json['typingUsers'] as List<dynamic>? ?? [];
    final isTyping = typingUsers.contains(otherUserId);

    return ConversationModel(
      id: doc.id,
      otherUser: otherUser,
      bookingId: json['bookingId'] as String?,
      lastMessage: lastMessage,
      unreadCount: unreadCount,
      isTyping: isTyping,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore({
    required String currentUserId,
    required ChatUser currentUser,
  }) {
    return {
      'participants': [currentUserId, otherUser.id],
      'participantDetails': {
        currentUserId: ChatUserModel.fromEntity(currentUser).toFirestore(),
        otherUser.id: ChatUserModel.fromEntity(otherUser).toFirestore(),
      },
      'bookingId': bookingId,
      'unreadCounts': {
        currentUserId: 0,
        otherUser.id: 0,
      },
      'typingUsers': [],
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ConversationModel.fromEntity(Conversation entity) {
    return ConversationModel(
      id: entity.id,
      otherUser: entity.otherUser,
      bookingId: entity.bookingId,
      lastMessage: entity.lastMessage,
      unreadCount: entity.unreadCount,
      isTyping: entity.isTyping,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
