import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_firestore_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatFirestoreDataSource _dataSource;

  ChatRepositoryImpl({required ChatFirestoreDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Stream<Either<Failure, List<Conversation>>> getConversations() {
    try {
      return _dataSource.getConversations().map((conversations) {
        return Right<Failure, List<Conversation>>(conversations);
      }).handleError((error) {
        return Left<Failure, List<Conversation>>(
          ServerFailure(message: error.toString()),
        );
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Conversation>> getConversation(
      String conversationId) async {
    try {
      final conversation = await _dataSource.getConversation(conversationId);
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> getOrCreateConversation({
    required String vendorId,
    String? bookingId,
  }) async {
    try {
      final conversation = await _dataSource.getOrCreateConversation(
        vendorId: vendorId,
        vendorName: 'Vendor', // Will be updated with actual vendor name
        bookingId: bookingId,
      );
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Message>>> getMessages(String conversationId) {
    try {
      return _dataSource.getMessages(conversationId).map((messages) {
        return Right<Failure, List<Message>>(messages);
      }).handleError((error) {
        return Left<Failure, List<Message>>(
          ServerFailure(message: error.toString()),
        );
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final message = await _dataSource.sendMessage(
        conversationId: conversationId,
        content: content,
        type: MessageType.text,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> sendImageMessage({
    required String conversationId,
    required String imagePath,
  }) async {
    try {
      // TODO: Upload image to Firebase Storage first
      // For now, just send the path as URL
      final message = await _dataSource.sendMessage(
        conversationId: conversationId,
        content: 'Sent an image',
        type: MessageType.image,
        imageUrl: imagePath,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      await _dataSource.markAsRead(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setTyping({
    required String conversationId,
    required bool isTyping,
  }) async {
    try {
      await _dataSource.setTyping(
        conversationId: conversationId,
        isTyping: isTyping,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
      String conversationId) async {
    try {
      await _dataSource.deleteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, int>> getTotalUnreadCount() {
    try {
      return _dataSource.getTotalUnreadCount().map((count) {
        return Right<Failure, int>(count);
      }).handleError((error) {
        return Left<Failure, int>(
          ServerFailure(message: error.toString()),
        );
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure(message: e.toString())));
    }
  }
}
