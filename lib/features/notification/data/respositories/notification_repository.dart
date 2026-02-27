import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/notification/data/datasources/remote/notification_remote_datasource.dart';
import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';
import 'package:sewa_hub/features/notification/domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepository(
    remoteDataSource: ref.watch(notificationRemoteDataSourceProvider),
  );
});

class NotificationRepository implements INotificationRepository {
  final NotificationRemoteDataSource _remote;

  NotificationRepository({required NotificationRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int size = 20,
  }) =>
      _remote.getNotifications(page: page, size: size);

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    // Derived from getNotifications — count unread locally
    final result = await _remote.getNotifications(page: 1, size: 100);
    return result.map((list) => list.where((n) => !n.isRead).length);
  }

  @override
  Future<Either<Failure, bool>> markAllRead() => _remote.markAllRead();

  @override
  Future<Either<Failure, bool>> markOneRead(String id) =>
      _remote.markOneRead(id);

  @override
  Future<Either<Failure, bool>> deleteAll() => _remote.deleteAll();
}