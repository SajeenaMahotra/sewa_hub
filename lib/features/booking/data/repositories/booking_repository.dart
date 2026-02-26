import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/booking/data/datasources/remote/booking_remote_datasource.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';
import 'package:sewa_hub/features/booking/domain/repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider<IBookingRepository>((ref) {
  return BookingRepository(
    remoteDataSource: ref.watch(bookingRemoteDataSourceProvider),
  );
});

class BookingRepository implements IBookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  BookingRepository({required BookingRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, BookingEntity>> createBooking({
    required String providerId,
    required DateTime scheduledAt,
    required String address,
    String? note,
    String severity = 'normal',
  }) async {
    final result = await _remoteDataSource.createBooking(
      providerId: providerId,
      scheduledAt: scheduledAt,
      address: address,
      note: note,
      severity: severity,
    );
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getMyBookings({
    int page = 1,
    int size = 10,
  }) async {
    final result =
        await _remoteDataSource.getMyBookings(page: page, size: size);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getProviderBookings({
    int page = 1,
    int size = 10,
  }) async {
    final result =
        await _remoteDataSource.getProviderBookings(page: page, size: size);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, BookingEntity>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final result = await _remoteDataSource.updateBookingStatus(
        bookingId: bookingId, status: status);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, BookingEntity>> cancelBooking(
      String bookingId) async {
    final result = await _remoteDataSource.cancelBooking(bookingId);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingById(
      String bookingId) async {
    final result = await _remoteDataSource.getBookingById(bookingId);
    return result.map((model) => model.toEntity());
  }
}