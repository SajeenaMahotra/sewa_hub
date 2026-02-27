import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String bookingId;
  final SenderEntity sender;
  final String senderRole;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.bookingId,
    required this.sender,
    required this.senderRole,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, bookingId, sender, senderRole, content, isRead, createdAt];
}

class SenderEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? imageUrl;

  const SenderEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, fullName, email, imageUrl];
}