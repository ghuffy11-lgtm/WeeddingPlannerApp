import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat_user.dart';
import '../../domain/entities/message.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatFirestoreDataSource {
  String get currentUserId;

  Stream<List<ConversationModel>> getConversations();

  Future<ConversationModel> getConversation(String conversationId);

  Future<ConversationModel> getOrCreateConversation({
    required String vendorId,
    required String vendorName,
    String? vendorAvatarUrl,
    String? bookingId,
  });

  Stream<List<MessageModel>> getMessages(String conversationId);

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    String? imageUrl,
  });

  Future<void> markAsRead(String conversationId);

  Future<void> setTyping({
    required String conversationId,
    required bool isTyping,
  });

  Future<void> deleteConversation(String conversationId);

  Stream<int> getTotalUnreadCount();
}

class ChatFirestoreDataSourceImpl implements ChatFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatFirestoreDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _conversationsRef =>
      _firestore.collection('conversations');

  CollectionReference<Map<String, dynamic>> _messagesRef(String conversationId) =>
      _conversationsRef.doc(conversationId).collection('messages');

  @override
  Stream<List<ConversationModel>> getConversations() {
    final userId = currentUserId;

    return _conversationsRef
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ConversationModel.fromFirestore(doc, currentUserId: userId);
      }).toList();
    });
  }

  @override
  Future<ConversationModel> getConversation(String conversationId) async {
    final doc = await _conversationsRef.doc(conversationId).get();

    if (!doc.exists) {
      throw Exception('Conversation not found');
    }

    return ConversationModel.fromFirestore(doc, currentUserId: currentUserId);
  }

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String vendorId,
    required String vendorName,
    String? vendorAvatarUrl,
    String? bookingId,
  }) async {
    final userId = currentUserId;

    // Check if conversation already exists
    final existing = await _conversationsRef
        .where('participants', arrayContains: userId)
        .get();

    for (final doc in existing.docs) {
      final participants = doc.data()['participants'] as List<dynamic>;
      if (participants.contains(vendorId)) {
        return ConversationModel.fromFirestore(doc, currentUserId: userId);
      }
    }

    // Create new conversation
    final now = DateTime.now();
    final currentUser = _auth.currentUser;

    final conversationData = {
      'participants': [userId, vendorId],
      'participantDetails': {
        userId: {
          'id': userId,
          'name': currentUser?.displayName ?? 'User',
          'avatarUrl': currentUser?.photoURL,
          'type': ChatUserType.couple.name,
          'isOnline': true,
          'lastSeen': Timestamp.fromDate(now),
        },
        vendorId: {
          'id': vendorId,
          'name': vendorName,
          'avatarUrl': vendorAvatarUrl,
          'type': ChatUserType.vendor.name,
          'isOnline': false,
          'lastSeen': null,
        },
      },
      'bookingId': bookingId,
      'unreadCounts': {
        userId: 0,
        vendorId: 0,
      },
      'typingUsers': <String>[],
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };

    final docRef = await _conversationsRef.add(conversationData);
    final newDoc = await docRef.get();

    return ConversationModel.fromFirestore(newDoc, currentUserId: userId);
  }

  @override
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _messagesRef(conversationId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    String? imageUrl,
  }) async {
    final userId = currentUserId;
    final now = DateTime.now();
    final currentUser = _auth.currentUser;

    final messageData = {
      'conversationId': conversationId,
      'senderId': userId,
      'senderName': currentUser?.displayName ?? 'User',
      'type': type.name,
      'content': content,
      'imageUrl': imageUrl,
      'status': MessageStatus.sent.name,
      'createdAt': Timestamp.fromDate(now),
      'readAt': null,
    };

    // Add message
    final docRef = await _messagesRef(conversationId).add(messageData);

    // Update conversation with last message
    final conversationDoc = await _conversationsRef.doc(conversationId).get();
    final participants = conversationDoc.data()?['participants'] as List<dynamic>? ?? [];
    final otherUserId = participants.firstWhere((p) => p != userId, orElse: () => null);

    await _conversationsRef.doc(conversationId).update({
      'lastMessage': {
        'id': docRef.id,
        'senderId': userId,
        'senderName': currentUser?.displayName ?? 'User',
        'type': type.name,
        'content': content,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(now),
      },
      'updatedAt': Timestamp.fromDate(now),
      if (otherUserId != null)
        'unreadCounts.$otherUserId': FieldValue.increment(1),
    });

    // Clear typing status
    await setTyping(conversationId: conversationId, isTyping: false);

    final newDoc = await docRef.get();
    return MessageModel.fromFirestore(newDoc);
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    final userId = currentUserId;

    // Reset unread count for current user
    await _conversationsRef.doc(conversationId).update({
      'unreadCounts.$userId': 0,
    });

    // Mark all unread messages as read
    final unreadMessages = await _messagesRef(conversationId)
        .where('senderId', isNotEqualTo: userId)
        .where('readAt', isNull: true)
        .get();

    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {
        'readAt': Timestamp.fromDate(DateTime.now()),
        'status': MessageStatus.read.name,
      });
    }
    await batch.commit();
  }

  @override
  Future<void> setTyping({
    required String conversationId,
    required bool isTyping,
  }) async {
    final userId = currentUserId;

    if (isTyping) {
      await _conversationsRef.doc(conversationId).update({
        'typingUsers': FieldValue.arrayUnion([userId]),
      });
    } else {
      await _conversationsRef.doc(conversationId).update({
        'typingUsers': FieldValue.arrayRemove([userId]),
      });
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    // Delete all messages first
    final messages = await _messagesRef(conversationId).get();
    final batch = _firestore.batch();

    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }

    // Delete conversation
    batch.delete(_conversationsRef.doc(conversationId));

    await batch.commit();
  }

  @override
  Stream<int> getTotalUnreadCount() {
    final userId = currentUserId;

    return _conversationsRef
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final unreadCounts = data['unreadCounts'] as Map<String, dynamic>? ?? {};
        total += (unreadCounts[userId] as int? ?? 0);
      }
      return total;
    });
  }
}
