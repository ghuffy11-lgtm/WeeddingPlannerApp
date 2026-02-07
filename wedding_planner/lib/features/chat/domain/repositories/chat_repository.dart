import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

/// Repository interface for chat operations
abstract class ChatRepository {
  /// Get all conversations for the current user
  Stream<Either<Failure, List<Conversation>>> getConversations();

  /// Get a single conversation by ID
  Future<Either<Failure, Conversation>> getConversation(String conversationId);

  /// Get or create a conversation with a vendor
  Future<Either<Failure, Conversation>> getOrCreateConversation({
    required String vendorId,
    String? bookingId,
  });

  /// Get messages for a conversation (real-time stream)
  Stream<Either<Failure, List<Message>>> getMessages(String conversationId);

  /// Send a text message
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
  });

  /// Send an image message
  Future<Either<Failure, Message>> sendImageMessage({
    required String conversationId,
    required String imagePath,
  });

  /// Mark messages as read
  Future<Either<Failure, void>> markAsRead(String conversationId);

  /// Set typing status
  Future<Either<Failure, void>> setTyping({
    required String conversationId,
    required bool isTyping,
  });

  /// Delete a conversation
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  /// Get unread count for all conversations
  Stream<Either<Failure, int>> getTotalUnreadCount();
}
