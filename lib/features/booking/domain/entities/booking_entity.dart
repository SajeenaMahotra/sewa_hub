import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String? id;
  final String userId;
  final String providerId;
  final DateTime scheduledAt;
  final String address;
  final String? note;
  final String phoneNumber;          
  final double pricePerHour;
  final String severity;
  final double effectivePricePerHour;
  final String status;
  final DateTime? createdAt;
  final dynamic user;
  final dynamic provider;

  const BookingEntity({
    this.id,
    required this.userId,
    required this.providerId,
    required this.scheduledAt,
    required this.address,
    this.note,
    required this.phoneNumber,       // ← new
    required this.pricePerHour,
    this.severity = 'normal',
    required this.effectivePricePerHour,
    this.status = 'pending',
    this.createdAt,
    this.user,
    this.provider,
  });

  @override
  List<Object?> get props => [
        id, userId, providerId, scheduledAt, address,
        note, phoneNumber, pricePerHour, severity,
        effectivePricePerHour, status, createdAt,
      ];
}