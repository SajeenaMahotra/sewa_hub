import 'package:sewa_hub/features/chat/domain/entities/message_entity.dart';

class SenderApiModel {
  final String id;
  final String fullName;
  final String email;
  final String? imageUrl;

  SenderApiModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.imageUrl,
  });

  factory SenderApiModel.fromJson(Map<String, dynamic> json) {
    return SenderApiModel(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  SenderEntity toEntity() {
    return SenderEntity(
      id: id,
      fullName: fullName,
      email: email,
      imageUrl: imageUrl,
    );
  }
}

class MessageApiModel {
  final String id;
  final String bookingId;
  final SenderApiModel sender;
  final String senderRole;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  MessageApiModel({
    required this.id,
    required this.bookingId,
    required this.sender,
    required this.senderRole,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageApiModel.fromJson(Map<String, dynamic> json) {
    // sender_id can be a populated object or just an id string
    final senderData = json['sender_id'];
    SenderApiModel sender;
    if (senderData is Map<String, dynamic>) {
      sender = SenderApiModel.fromJson(senderData);
    } else {
      sender = SenderApiModel(
        id: senderData?.toString() ?? '',
        fullName: 'Unknown',
        email: '',
      );
    }

    return MessageApiModel(
      id: json['_id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      sender: sender,
      senderRole: json['sender_role']?.toString() ?? 'user',
      content: json['content']?.toString() ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      bookingId: bookingId,
      sender: sender.toEntity(),
      senderRole: senderRole,
      content: content,
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}