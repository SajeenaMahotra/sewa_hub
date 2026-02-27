import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/notification/data/respositories/notification_repository.dart';
import 'package:sewa_hub/features/notification/domain/repositories/notification_repository.dart';

//  Mark All Read 
final markAllReadUsecaseProvider = Provider<MarkAllReadUsecase>((ref) {
  return MarkAllReadUsecase(
      repository: ref.watch(notificationRepositoryProvider));
});

class MarkAllReadUsecase {
  final INotificationRepository _repository;
  MarkAllReadUsecase({required INotificationRepository repository})
      : _repository = repository;

  Future<Either<Failure, bool>> call() => _repository.markAllRead();
}

//  Mark One Read
final markOneReadUsecaseProvider = Provider<MarkOneReadUsecase>((ref) {
  return MarkOneReadUsecase(
      repository: ref.watch(notificationRepositoryProvider));
});

class MarkOneReadUsecase {
  final INotificationRepository _repository;
  MarkOneReadUsecase({required INotificationRepository repository})
      : _repository = repository;

  Future<Either<Failure, bool>> call(String id) =>
      _repository.markOneRead(id);
}

//  Delete All 
final deleteAllNotificationsUsecaseProvider =
    Provider<DeleteAllNotificationsUsecase>((ref) {
  return DeleteAllNotificationsUsecase(
      repository: ref.watch(notificationRepositoryProvider));
});

class DeleteAllNotificationsUsecase {
  final INotificationRepository _repository;
  DeleteAllNotificationsUsecase({required INotificationRepository repository})
      : _repository = repository;

  Future<Either<Failure, bool>> call() => _repository.deleteAll();
}