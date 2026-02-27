import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';

class NotificationApiModel {
  final String id;
  final String recipientId;
  final String type;
  final String title;
  final String message;
  final String? bookingId;
  final bool isRead;
  final DateTime createdAt;

  NotificationApiModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.message,
    this.bookingId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationApiModel(
      id:          json['_id']          as String? ?? '',
      recipientId: json['recipient_id'] as String? ?? '',
      type:        json['type']         as String? ?? '',
      title:       json['title']        as String? ?? '',
      message:     json['message']      as String? ?? '',
      bookingId:   json['booking_id']   as String?,
      isRead:      json['is_read']      as bool?   ?? false,
      createdAt:   json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id:          id,
      recipientId: recipientId,
      type:        notificationTypeFromString(type),
      title:       title,
      message:     message,
      bookingId:   bookingId,
      isRead:      isRead,
      createdAt:   createdAt,
    );
  }
}