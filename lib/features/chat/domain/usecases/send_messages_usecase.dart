import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/chat/data/repositories/chat_repository.dart';
import 'package:sewa_hub/features/chat/domain/entities/message_entity.dart';
import 'package:sewa_hub/features/chat/domain/repositories/chat_repository.dart';

class SendMessageParam extends Equatable {
  final String bookingId;
  final String content;

  const SendMessageParam({
    required this.bookingId,
    required this.content,
  });

  @override
  List<Object?> get props => [bookingId, content];
}

final sendMessageUsecaseProvider = Provider<SendMessageUsecase>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return SendMessageUsecase(repository: repo);
});

class SendMessageUsecase implements UsecaseWithParams<MessageEntity, SendMessageParam> {
  final IChatRepository _repository;

  SendMessageUsecase({required IChatRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParam params) {
    return _repository.sendMessage(
      bookingId: params.bookingId,
      content: params.content,
    );
  }
}