import 'package:dartz/dartz.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';

abstract class IBookingRepository {
  Future<Either<Failure, BookingEntity>> createBooking({
    required String providerId,
    required DateTime scheduledAt,
    required String address,
    required String phoneNumber,     // ← new
    String? note,
    String severity,
  });

  Future<Either<Failure, List<BookingEntity>>> getMyBookings({
    int page = 1,
    int size = 10,
  });

  Future<Either<Failure, List<BookingEntity>>> getProviderBookings({
    int page = 1,
    int size = 10,
  });

  Future<Either<Failure, BookingEntity>> updateBookingStatus({
    required String bookingId,
    required String status,
  });

  Future<Either<Failure, BookingEntity>> cancelBooking(String bookingId);
  Future<Either<Failure, BookingEntity>> getBookingById(String bookingId);

  // ── Rating ──────────────────────────────────────────────────────────────
  Future<Either<Failure, void>> rateProvider({
    required String bookingId,
    required int rating,            // 1–5
  });
}