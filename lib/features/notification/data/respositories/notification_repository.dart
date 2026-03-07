import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/services/connectivity/network_info.dart';
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:sewa_hub/features/notification/data/datasources/local/notification_local_datasource.dart';
import 'package:sewa_hub/features/notification/data/datasources/remote/notification_remote_datasource.dart';
import 'package:sewa_hub/features/notification/data/models/notification_hive_model.dart';
import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';
import 'package:sewa_hub/features/notification/domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepository(
    remoteDataSource: ref.watch(notificationRemoteDataSourceProvider),
    localDataSource: ref.watch(notificationLocalDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    userSessionService: ref.watch(userSessionServiceProvider),
  );
});

class NotificationRepository implements INotificationRepository {
  final NotificationRemoteDataSource _remote;
  final INotificationLocalDatasource _local;
  final NetworkInfo _networkInfo;
  final UserSessionService _userSessionService;

  NotificationRepository({
    required NotificationRemoteDataSource remoteDataSource,
    required INotificationLocalDatasource localDataSource,
    required NetworkInfo networkInfo,
    required UserSessionService userSessionService,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _networkInfo = networkInfo,
        _userSessionService = userSessionService;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int size = 20,
  }) async {
    if (await _networkInfo.isConnected) {
      final result = await _remote.getNotifications(page: page, size: size);
      return result.fold(
        (failure) => _getFromCache(), // remote failed → cache
        (list) async {
          // Cache fresh notifications
          final recipientId = _userSessionService.userId;
          if (recipientId != null) {
            await _local.saveNotifications(
              list.map(NotificationHiveModel.fromEntity).toList(),
            );
          }
          return Right(list);
        },
      );
    } else {
      return _getFromCache(); // Offline → cache
    }
  }

  Future<Either<Failure, List<NotificationEntity>>> _getFromCache() async {
    try {
      final recipientId = _userSessionService.userId;
      if (recipientId == null) {
        return const Left(LocalDatabaseFailure(message: 'No session found'));
      }
      final cached = await _local.getNotifications(recipientId);
      return Right(cached.map((n) => n.toEntity()).toList());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    final result = await getNotifications(page: 1, size: 100);
    return result.map((list) => list.where((n) => !n.isRead).length);
  }

  @override
  Future<Either<Failure, bool>> markAllRead() async {
    final result = await _remote.markAllRead();
    return result.fold(
      (failure) => Left(failure),
      (_) async {
        // Sync cache
        final recipientId = _userSessionService.userId;
        if (recipientId != null) await _local.markAllRead(recipientId);
        return const Right(true);
      },
    );
  }

  @override
  Future<Either<Failure, bool>> markOneRead(String id) async {
    final result = await _remote.markOneRead(id);
    return result.fold(
      (failure) => Left(failure),
      (_) async {
        await _local.markOneRead(id); // Sync cache
        return const Right(true);
      },
    );
  }

  @override
  Future<Either<Failure, bool>> deleteAll() async {
    final result = await _remote.deleteAll();
    return result.fold(
      (failure) => Left(failure),
      (_) async {
        final recipientId = _userSessionService.userId;
        if (recipientId != null) await _local.deleteAll(recipientId); 
        return const Right(true);
      },
    );
  }
}