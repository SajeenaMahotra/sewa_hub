import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/booking/data/repositories/booking_repository.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';
import 'package:sewa_hub/features/booking/domain/repositories/booking_repository.dart';

// ── Create Booking ────────────────────────────────────────────────────────────

class CreateBookingParams extends Equatable {
  final String providerId;
  final DateTime scheduledAt;
  final String address;
  final String phoneNumber;          // ← new
  final String? note;
  final String severity;

  const CreateBookingParams({
    required this.providerId,
    required this.scheduledAt,
    required this.address,
    required this.phoneNumber,       // ← new
    this.note,
    this.severity = 'normal',
  });

  @override
  List<Object?> get props =>
      [providerId, scheduledAt, address, phoneNumber, note, severity];
}

final createBookingUsecaseProvider = Provider<CreateBookingUsecase>((ref) {
  return CreateBookingUsecase(
    repository: ref.watch(bookingRepositoryProvider),
  );
});

class CreateBookingUsecase
    implements UsecaseWithParams<BookingEntity, CreateBookingParams> {
  final IBookingRepository _repository;
  CreateBookingUsecase({required IBookingRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, BookingEntity>> call(CreateBookingParams params) {
    return _repository.createBooking(
      providerId:  params.providerId,
      scheduledAt: params.scheduledAt,
      address:     params.address,
      phoneNumber: params.phoneNumber,   // ← new
      note:        params.note,
      severity:    params.severity,
    );
  }
}

// ── Rate Provider ─────────────────────────────────────────────────────────────

class RateProviderParams extends Equatable {
  final String bookingId;
  final int rating;                  // 1–5

  const RateProviderParams({required this.bookingId, required this.rating});

  @override
  List<Object?> get props => [bookingId, rating];
}

final rateProviderUsecaseProvider = Provider<RateProviderUsecase>((ref) {
  return RateProviderUsecase(repository: ref.watch(bookingRepositoryProvider));
});

class RateProviderUsecase
    implements UsecaseWithParams<void, RateProviderParams> {
  final IBookingRepository _repository;
  RateProviderUsecase({required IBookingRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, void>> call(RateProviderParams params) {
    return _repository.rateProvider(
        bookingId: params.bookingId, rating: params.rating);
  }
}