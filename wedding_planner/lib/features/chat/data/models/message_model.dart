import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    super.senderName,
    required super.type,
    required super.content,
    super.imageUrl,
    required super.status,
    required super.createdAt,
    super.readAt,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String?,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      readAt: json['readAt'] != null
          ? (json['readAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'type': type.name,
      'content': content,
      'imageUrl': imageUrl,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  factory MessageModel.fromEntity(Message entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      type: entity.type,
      content: entity.content,
      imageUrl: entity.imageUrl,
      status: entity.status,
      createdAt: entity.createdAt,
      readAt: entity.readAt,
    );
  }
}
