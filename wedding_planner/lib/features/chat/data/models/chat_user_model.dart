import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_user.dart';

class ChatUserModel extends ChatUser {
  const ChatUserModel({
    required super.id,
    required super.name,
    super.avatarUrl,
    required super.type,
    super.isOnline,
    super.lastSeen,
  });

  factory ChatUserModel.fromFirestore(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      type: ChatUserType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChatUserType.couple,
      ),
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? (json['lastSeen'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'type': type.name,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }

  factory ChatUserModel.fromEntity(ChatUser entity) {
    return ChatUserModel(
      id: entity.id,
      name: entity.name,
      avatarUrl: entity.avatarUrl,
      type: entity.type,
      isOnline: entity.isOnline,
      lastSeen: entity.lastSeen,
    );
  }
}
