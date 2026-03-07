import 'package:hive/hive.dart';
import 'package:sewa_hub/core/constants/hive_table_constants.dart';
import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';

part 'notification_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.notificationTypeId)
class NotificationHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String recipientId;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String message;

  @HiveField(5)
  final String? bookingId;

  @HiveField(6)
  final bool isRead;

  @HiveField(7)
  final DateTime createdAt;

  NotificationHiveModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.message,
    this.bookingId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationHiveModel.fromEntity(NotificationEntity entity) {
    return NotificationHiveModel(
      id: entity.id,
      recipientId: entity.recipientId,
      type: entity.type.name,
      title: entity.title,
      message: entity.message,
      bookingId: entity.bookingId,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      recipientId: recipientId,
      type: notificationTypeFromString(type),
      title: title,
      message: message,
      bookingId: bookingId,
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}