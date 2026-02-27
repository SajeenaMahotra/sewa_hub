import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/api/api_client.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/chat/data/models/message_api_model.dart';
import 'package:sewa_hub/features/chat/domain/entities/message_entity.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatRemoteDataSource(apiClient: apiClient);
});

class ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String bookingId,
    int page = 1,
    int size = 30,
  }) async {
    try {
      final response = await _apiClient.get(
        '/chat/$bookingId',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final messagesList = data['messages'] as List<dynamic>;
        final messages = messagesList
            .map((m) => MessageApiModel.fromJson(m as Map<String, dynamic>).toEntity())
            .toList();
        return Right(messages);
      }

      return Left(NetworkFailure(error: response.data['message'] ?? 'Failed to get messages'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String bookingId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.post('/chat', data: {
        'booking_id': bookingId,
        'content': content,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Right(MessageApiModel.fromJson(data).toEntity());
      }

      return Left(NetworkFailure(error: response.data['message'] ?? 'Failed to send message'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, bool>> markAsRead({required String bookingId}) async {
    try {
      final response = await _apiClient.patch('/chat/$bookingId/read');

      if (response.data['success'] == true) {
        return const Right(true);
      }

      return Left(NetworkFailure(error: response.data['message'] ?? 'Failed to mark as read'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, int>> getUnreadCount({required String bookingId}) async {
    try {
      final response = await _apiClient.get('/chat/$bookingId/unread');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Right(data['unread'] as int? ?? 0);
      }

      return Left(NetworkFailure(error: response.data['message'] ?? 'Failed to get unread count'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }
}