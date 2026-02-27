import 'package:dartz/dartz.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';

abstract class INotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int size = 20,
  });

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, bool>> markAllRead();

  Future<Either<Failure, bool>> markOneRead(String notificationId);

  Future<Either<Failure, bool>> deleteAll();
}