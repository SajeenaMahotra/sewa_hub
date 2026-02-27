import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/api/api_client.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/notification/data/models/notification_api_model.dart';
import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource(apiClient: ref.watch(apiClientProvider));
});

class NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/notifications',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final list = (data['notifications'] as List<dynamic>? ?? [])
            .map((e) =>
                NotificationApiModel.fromJson(e as Map<String, dynamic>)
                    .toEntity())
            .toList();
        return Right(list);
      }
      return Left(NetworkFailure(
          error: response.data['message'] ?? 'Failed to load notifications'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, bool>> markAllRead() async {
    try {
      final response = await _apiClient.patch('/notifications/read-all');
      if (response.data['success'] == true) return const Right(true);
      return Left(NetworkFailure(error: response.data['message'] ?? 'Failed'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, bool>> markOneRead(String id) async {
    try {
      final response = await _apiClient.patch('/notifications/$id/read');
      if (response.data['success'] == true) return const Right(true);
      return Left(NetworkFailure(error: response.data['message'] ?? 'Failed'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, bool>> deleteAll() async {
    try {
      final response = await _apiClient.delete('/notifications');
      if (response.data['success'] == true) return const Right(true);
      return Left(NetworkFailure(error: response.data['message'] ?? 'Failed'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }
}