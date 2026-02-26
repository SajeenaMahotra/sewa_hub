import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/api/api_client.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/booking/data/models/booking_api_model.dart';

final bookingRemoteDataSourceProvider =
    Provider<BookingRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRemoteDataSource(apiClient: apiClient);
});

class BookingRemoteDataSource {
  final ApiClient _apiClient;

  BookingRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<Either<Failure, BookingApiModel>> createBooking({
    required String providerId,
    required DateTime scheduledAt,
    required String address,
    String? note,
    String severity = 'normal',
  }) async {
    try {
      final response = await _apiClient.post('/bookings', data: {
        'provider_id': providerId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'address': address,
        if (note != null && note.isNotEmpty) 'note': note,
        'severity': severity,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Right(BookingApiModel.fromJson(data));
      }
      return Left(NetworkFailure(
          error: response.data['message'] ?? 'Failed to create booking'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, List<BookingApiModel>>> getMyBookings({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await _apiClient
          .get('/bookings/mybooking?page=$page&size=$size');

      if (response.data['success'] == true) {
        final bookings = (response.data['data']['bookings'] as List)
            .map((e) => BookingApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(bookings);
      }
      return Left(NetworkFailure(
          error: response.data['message'] ?? 'Failed to fetch bookings'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, List<BookingApiModel>>> getProviderBookings({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await _apiClient
          .get('/bookings/provider?page=$page&size=$size');

      if (response.data['success'] == true) {
        final bookings = (response.data['data']['bookings'] as List)
            .map((e) => BookingApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(bookings);
      }
      return Left(NetworkFailure(
          error: response.data['message'] ?? 'Failed to fetch bookings'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, BookingApiModel>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/bookings/$bookingId/status',
        data: {'status': status},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Right(BookingApiModel.fromJson(data));
      }
      return Left(NetworkFailure(
          error: response.data['message'] ?? 'Failed to update status'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, BookingApiModel>> cancelBooking(
      String bookingId) async {
    try {
      final response =
          await _apiClient.patch('/bookings/$bookingId/cancel');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Right(BookingApiModel.fromJson(data));
      }
      return Left(NetworkFailure(
          error: response.data['message'] ?? 'Failed to cancel booking'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, BookingApiModel>> getBookingById(
      String bookingId) async {
    try {
      final response = await _apiClient.get('/bookings/$bookingId');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Right(BookingApiModel.fromJson(data));
      }
      return Left(NetworkFailure(
          error: response.data['message'] ?? 'Booking not found'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }
}