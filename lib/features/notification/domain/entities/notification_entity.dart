import 'package:equatable/equatable.dart';

enum NotificationType {
  bookingCreated,
  bookingAccepted,
  bookingRejected,
  bookingCompleted,
  bookingCancelled,
  unknown,
}

NotificationType notificationTypeFromString(String? value) {
  switch (value) {
    case 'booking_created':   return NotificationType.bookingCreated;
    case 'booking_accepted':  return NotificationType.bookingAccepted;
    case 'booking_rejected':  return NotificationType.bookingRejected;
    case 'booking_completed': return NotificationType.bookingCompleted;
    case 'booking_cancelled': return NotificationType.bookingCancelled;
    default:                  return NotificationType.unknown;
  }
}

class NotificationEntity extends Equatable {
  final String id;
  final String recipientId;
  final NotificationType type;
  final String title;
  final String message;
  final String? bookingId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.message,
    this.bookingId,
    required this.isRead,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id:          id,
      recipientId: recipientId,
      type:        type,
      title:       title,
      message:     message,
      bookingId:   bookingId,
      isRead:      isRead ?? this.isRead,
      createdAt:   createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, recipientId, type, title, message, bookingId, isRead, createdAt];
}