import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/chat/data/repositories/chat_repository.dart';
import 'package:sewa_hub/features/chat/domain/repositories/chat_repository.dart';

class MarkAsReadParam extends Equatable {
  final String bookingId;

  const MarkAsReadParam({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

final markAsReadUsecaseProvider = Provider<MarkAsReadUsecase>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return MarkAsReadUsecase(repository: repo);
});

class MarkAsReadUsecase implements UsecaseWithParams<bool, MarkAsReadParam> {
  final IChatRepository _repository;

  MarkAsReadUsecase({required IChatRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(MarkAsReadParam params) {
    return _repository.markAsRead(bookingId: params.bookingId);
  }
}