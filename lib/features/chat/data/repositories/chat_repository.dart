import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'package:sewa_hub/features/chat/domain/entities/message_entity.dart';
import 'package:sewa_hub/features/chat/domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  final remote = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepository(remoteDataSource: remote);
});

class ChatRepository implements IChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepository({required ChatRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String bookingId,
    int page = 1,
    int size = 30,
  }) {
    return _remoteDataSource.getMessages(bookingId: bookingId, page: page, size: size);
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String bookingId,
    required String content,
  }) {
    return _remoteDataSource.sendMessage(bookingId: bookingId, content: content);
  }

  @override
  Future<Either<Failure, bool>> markAsRead({required String bookingId}) {
    return _remoteDataSource.markAsRead(bookingId: bookingId);
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({required String bookingId}) {
    return _remoteDataSource.getUnreadCount(bookingId: bookingId);
  }
}