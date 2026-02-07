import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/chat_firestore_datasource.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final ChatFirestoreDataSource _dataSource;

  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _unreadCountSubscription;

  ChatBloc({
    required ChatRepository repository,
    required ChatFirestoreDataSource dataSource,
  })  : _repository = repository,
        _dataSource = dataSource,
        super(const ChatState()) {
    on<LoadConversations>(_onLoadConversations);
    on<ConversationsUpdated>(_onConversationsUpdated);
    on<LoadMessages>(_onLoadMessages);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<SendMessage>(_onSendMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<MarkAsRead>(_onMarkAsRead);
    on<SetTyping>(_onSetTyping);
    on<StartConversation>(_onStartConversation);
    on<DeleteConversation>(_onDeleteConversation);
    on<ClearCurrentConversation>(_onClearCurrentConversation);
    on<ClearChatError>(_onClearChatError);
    on<UnreadCountUpdated>(_onUnreadCountUpdated);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(conversationsStatus: ChatStatus.loading));

    await _conversationsSubscription?.cancel();
    await _unreadCountSubscription?.cancel();

    _conversationsSubscription = _repository.getConversations().listen(
      (result) {
        result.fold(
          (failure) => add(ConversationsUpdated(const [])),
          (conversations) => add(ConversationsUpdated(conversations)),
        );
      },
      onError: (error) {
        add(const ConversationsUpdated([]));
      },
    );

    _unreadCountSubscription = _repository.getTotalUnreadCount().listen(
      (result) {
        result.fold(
          (_) {},
          (count) => add(UnreadCountUpdated(count)),
        );
      },
    );
  }

  void _onConversationsUpdated(
    ConversationsUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      conversationsStatus: ChatStatus.loaded,
      conversations: event.conversations,
    ));
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(
      messagesStatus: MessagesLoadStatus.loading,
      currentConversationId: event.conversationId,
    ));

    await _messagesSubscription?.cancel();

    // Get conversation details
    final conversationResult =
        await _repository.getConversation(event.conversationId);
    conversationResult.fold(
      (failure) {},
      (conversation) {
        emit(state.copyWith(currentConversation: conversation));
      },
    );

    _messagesSubscription =
        _repository.getMessages(event.conversationId).listen(
      (result) {
        result.fold(
          (failure) => add(const MessagesUpdated([])),
          (messages) => add(MessagesUpdated(messages)),
        );
      },
      onError: (error) {
        add(const MessagesUpdated([]));
      },
    );

    // Mark as read
    add(MarkAsRead(event.conversationId));
  }

  void _onMessagesUpdated(
    MessagesUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      messagesStatus: MessagesLoadStatus.loaded,
      messages: event.messages,
    ));
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isSending: true));

    final result = await _repository.sendMessage(
      conversationId: event.conversationId,
      content: event.content,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSending: false,
        sendError: failure.message,
      )),
      (_) => emit(state.copyWith(isSending: false)),
    );
  }

  Future<void> _onSendImageMessage(
    SendImageMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isSending: true));

    final result = await _repository.sendImageMessage(
      conversationId: event.conversationId,
      imagePath: event.imagePath,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSending: false,
        sendError: failure.message,
      )),
      (_) => emit(state.copyWith(isSending: false)),
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<ChatState> emit,
  ) async {
    await _repository.markAsRead(event.conversationId);
  }

  Future<void> _onSetTyping(
    SetTyping event,
    Emitter<ChatState> emit,
  ) async {
    await _repository.setTyping(
      conversationId: event.conversationId,
      isTyping: event.isTyping,
    );
  }

  Future<void> _onStartConversation(
    StartConversation event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(messagesStatus: MessagesLoadStatus.loading));

    try {
      final conversation = await _dataSource.getOrCreateConversation(
        vendorId: event.vendorId,
        vendorName: event.vendorName,
        vendorAvatarUrl: event.vendorAvatarUrl,
        bookingId: event.bookingId,
      );

      emit(state.copyWith(
        currentConversationId: conversation.id,
        currentConversation: conversation,
      ));

      // Load messages for the new conversation
      add(LoadMessages(conversation.id));
    } catch (e) {
      emit(state.copyWith(
        messagesStatus: MessagesLoadStatus.error,
        messagesError: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<ChatState> emit,
  ) async {
    await _repository.deleteConversation(event.conversationId);

    // Remove from local list
    final updatedConversations = state.conversations
        .where((c) => c.id != event.conversationId)
        .toList();

    emit(state.copyWith(conversations: updatedConversations));
  }

  void _onClearCurrentConversation(
    ClearCurrentConversation event,
    Emitter<ChatState> emit,
  ) {
    _messagesSubscription?.cancel();
    emit(state.copyWith(
      clearCurrentConversation: true,
      messagesStatus: MessagesLoadStatus.initial,
    ));
  }

  void _onClearChatError(
    ClearChatError event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      clearConversationsError: true,
      clearMessagesError: true,
      clearSendError: true,
    ));
  }

  void _onUnreadCountUpdated(
    UnreadCountUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(totalUnreadCount: event.count));
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    return super.close();
  }
}
