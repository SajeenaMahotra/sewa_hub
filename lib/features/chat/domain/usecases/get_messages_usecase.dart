import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/chat/data/repositories/chat_repository.dart';
import 'package:sewa_hub/features/chat/domain/entities/message_entity.dart';
import 'package:sewa_hub/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesParam extends Equatable {
  final String bookingId;
  final int page;
  final int size;

  const GetMessagesParam({
    required this.bookingId,
    this.page = 1,
    this.size = 30,
  });

  @override
  List<Object?> get props => [bookingId, page, size];
}

final getMessagesUsecaseProvider = Provider<GetMessagesUsecase>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return GetMessagesUsecase(repository: repo);
});

class GetMessagesUsecase implements UsecaseWithParams<List<MessageEntity>, GetMessagesParam> {
  final IChatRepository _repository;

  GetMessagesUsecase({required IChatRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, List<MessageEntity>>> call(GetMessagesParam params) {
    return _repository.getMessages(
      bookingId: params.bookingId,
      page: params.page,
      size: params.size,
    );
  }
}