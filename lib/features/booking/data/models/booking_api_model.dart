import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';

class BookingApiModel {
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
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? provider;

  BookingApiModel({
    this.id,
    required this.userId,
    required this.providerId,
    required this.scheduledAt,
    required this.address,
    this.note,
    required this.phoneNumber,     
    required this.pricePerHour,
    this.severity = 'normal',
    required this.effectivePricePerHour,
    this.status = 'pending',
    this.createdAt,
    this.user,
    this.provider,
  });

  factory BookingApiModel.fromJson(Map<String, dynamic> json) {
    final userIdRaw     = json['user_id'];
    final providerIdRaw = json['provider_id'];

    String userId   = '';
    String providerId = '';
    Map<String, dynamic>? userMap;
    Map<String, dynamic>? providerMap;

    if (userIdRaw is Map<String, dynamic>) {
      userId  = userIdRaw['_id']?.toString() ?? '';
      userMap = userIdRaw;
    } else {
      userId = userIdRaw?.toString() ?? '';
    }

    if (providerIdRaw is Map<String, dynamic>) {
      providerId  = providerIdRaw['_id']?.toString() ?? '';
      providerMap = providerIdRaw;
    } else {
      providerId = providerIdRaw?.toString() ?? '';
    }

    final basePrice     = (json['price_per_hour'] as num?)?.toDouble() ?? 0.0;
    final effectivePrice =
        (json['effective_price_per_hour'] as num?)?.toDouble() ?? basePrice;

    return BookingApiModel(
      id:                    json['_id']?.toString(),
      userId:                userId,
      providerId:            providerId,
      scheduledAt:           DateTime.parse(json['scheduled_at'] as String),
      address:               json['address'] as String? ?? '',
      note:                  json['note'] as String?,
      phoneNumber:           json['phone_number'] as String? ?? '',  // ← new
      pricePerHour:          basePrice,
      severity:              json['severity'] as String? ?? 'normal',
      effectivePricePerHour: effectivePrice,
      status:                json['status'] as String? ?? 'pending',
      createdAt:             json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      user:     userMap,
      provider: providerMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_id':  providerId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'address':      address,
      'phone_number': phoneNumber,   // ← new
      if (note != null) 'note': note,
      'severity':     severity,
    };
  }

  BookingEntity toEntity() {
    return BookingEntity(
      id:                    id,
      userId:                userId,
      providerId:            providerId,
      scheduledAt:           scheduledAt,
      address:               address,
      note:                  note,
      phoneNumber:           phoneNumber,   // ← new
      pricePerHour:          pricePerHour,
      severity:              severity,
      effectivePricePerHour: effectivePricePerHour,
      status:                status,
      createdAt:             createdAt,
      user:                  user,
      provider:              provider,
    );
  }
}