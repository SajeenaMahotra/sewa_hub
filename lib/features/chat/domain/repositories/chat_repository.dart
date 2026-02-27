import 'package:dartz/dartz.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/chat/domain/entities/message_entity.dart';

abstract class IChatRepository {
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String bookingId,
    int page = 1,
    int size = 30,
  });

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String bookingId,
    required String content,
  });

  Future<Either<Failure, bool>> markAsRead({required String bookingId});

  Future<Either<Failure, int>> getUnreadCount({required String bookingId});
}