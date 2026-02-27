import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/notification/data/respositories/notification_repository.dart';
import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';
import 'package:sewa_hub/features/notification/domain/repositories/notification_repository.dart';

final getNotificationsUsecaseProvider = Provider<GetNotificationsUsecase>((ref) {
  return GetNotificationsUsecase(
    repository: ref.watch(notificationRepositoryProvider),
  );
});

class GetNotificationsUsecase {
  final INotificationRepository _repository;
  GetNotificationsUsecase({required INotificationRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<NotificationEntity>>> call({
    int page = 1,
    int size = 20,
  }) =>
      _repository.getNotifications(page: page, size: size);
}