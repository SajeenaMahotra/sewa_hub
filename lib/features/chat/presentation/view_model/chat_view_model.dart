import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sewa_hub/core/services/socket_service.dart';
import 'package:sewa_hub/features/chat/data/models/message_api_model.dart';
import 'package:sewa_hub/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:sewa_hub/features/chat/domain/usecases/mark_as_read_usecase.dart';
import 'package:sewa_hub/features/chat/domain/usecases/send_messages_usecase.dart';
import 'package:sewa_hub/features/chat/presentation/state/chat_state.dart';

final chatViewModelProvider =
    StateNotifierProvider.family<ChatViewModel, ChatState, String>(
  (ref, bookingId) => ChatViewModel(ref: ref, bookingId: bookingId),
);

class ChatViewModel extends StateNotifier<ChatState> {
  final Ref _ref;
  final String _bookingId;

  late final GetMessagesUsecase _getMessagesUsecase;
  late final SendMessageUsecase _sendMessageUsecase;
  late final MarkAsReadUsecase _markAsReadUsecase;
  late final SocketService _socketService;

  ChatViewModel({required Ref ref, required String bookingId})
      : _ref = ref,
        _bookingId = bookingId,
        super(const ChatState()) {
    _getMessagesUsecase = _ref.read(getMessagesUsecaseProvider);
    _sendMessageUsecase = _ref.read(sendMessageUsecaseProvider);
    _markAsReadUsecase = _ref.read(markAsReadUsecaseProvider);
    _socketService = _ref.read(socketServiceProvider);
  }

  @override
  void dispose() {
    _socketService.leaveRoom(_bookingId);
    _socketService.off('new_message');
    _socketService.off('messages_read');
    _socketService.off('user_typing');
    _socketService.off('user_stopped_typing');
    _socketService.off('room_joined');
    _socketService.off('error');
    super.dispose();
  }

  void initSocket() {
    // Register listeners FIRST, then connect+join
    // socket_service queues joinRoom if not yet connected
    _registerSocketListeners();
    _socketService.connect();
    _socketService.joinRoom(_bookingId);
  }

  void _registerSocketListeners() {
    _socketService.onNewMessage((data) {
      print('[Chat] new_message: $data');
      try {
        final message = MessageApiModel.fromJson(
          Map<String, dynamic>.from(data as Map),
        ).toEntity();
        final exists = state.messages.any((m) => m.id == message.id);
        if (!exists) {
          state = state.copyWith(messages: [...state.messages, message]);
        }
      } catch (e) {
        print('[Chat] new_message parse error: $e');
      }
    });

    _socketService.onRoomJoined((data) {
      print('[Chat] room_joined: $data');
      try {
        final raw = data as Map;
        final messagesList = raw['messages'] as List<dynamic>? ?? [];
        final messages = messagesList
            .map((m) => MessageApiModel.fromJson(
                  Map<String, dynamic>.from(m as Map),
                ).toEntity())
            .toList();
        state = state.copyWith(status: ChatStatus.loaded, messages: messages);
      } catch (e) {
        print('[Chat] room_joined parse error: $e');
      }
    });

    _socketService.onMessagesRead((_) {});

    _socketService.onUserTyping((_) =>
        state = state.copyWith(isPartnerTyping: true));

    _socketService.onUserStoppedTyping((_) =>
        state = state.copyWith(isPartnerTyping: false));

    _socketService.onError((data) =>
        print('[Chat] socket error: $data'));
  }

  Future<void> loadMessages({bool refresh = false}) async {
    if (!refresh && state.status == ChatStatus.loaded) return;

    state = state.copyWith(status: ChatStatus.loading);
    final result = await _getMessagesUsecase.call(
      GetMessagesParam(bookingId: _bookingId, page: 1),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: failure.toString(),
      ),
      (messages) => state = state.copyWith(
        status: ChatStatus.loaded,
        messages: messages,
        currentPage: 1,
        hasMore: messages.length >= 30,
      ),
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    state = state.copyWith(isSending: true);

    print('[Chat] sendMessage — isConnected=${_socketService.isConnected}');

    if (_socketService.isConnected) {
      _socketService.sendMessage(_bookingId, content.trim());
      state = state.copyWith(isSending: false);
    } else {
      // REST fallback — message will appear immediately
      print('[Chat] socket not connected, falling back to REST');
      final result = await _sendMessageUsecase.call(
        SendMessageParam(bookingId: _bookingId, content: content.trim()),
      );
      result.fold(
        (failure) => state = state.copyWith(
          isSending: false,
          status: ChatStatus.error,
          errorMessage: failure.toString(),
        ),
        (message) => state = state.copyWith(
          isSending: false,
          messages: [...state.messages, message],
        ),
      );
    }
  }

  void startTyping() => _socketService.typingStart(_bookingId);
  void stopTyping() => _socketService.typingStop(_bookingId);

  void markRead() {
    _socketService.markRead(_bookingId);
    _markAsReadUsecase.call(MarkAsReadParam(bookingId: _bookingId));
  }
}