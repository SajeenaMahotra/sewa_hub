import 'package:equatable/equatable.dart';
import 'package:sewa_hub/features/chat/domain/entities/message_entity.dart';

enum ChatStatus { initial, loading, loaded, sending, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<MessageEntity> messages;
  final int total;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;
  final bool isSending;
  final bool isPartnerTyping;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.total = 0,
    this.currentPage = 1,
    this.hasMore = true,
    this.errorMessage,
    this.isSending = false,
    this.isPartnerTyping = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<MessageEntity>? messages,
    int? total,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
    bool? isSending,
    bool? isPartnerTyping,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
      isSending: isSending ?? this.isSending,
      isPartnerTyping: isPartnerTyping ?? this.isPartnerTyping,
    );
  }

  @override
  List<Object?> get props =>
      [status, messages, total, currentPage, hasMore, errorMessage, isSending, isPartnerTyping];
}