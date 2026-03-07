import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/api/api_client.dart';
import 'package:sewa_hub/core/api/api_endpoints.dart';
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
    required String phoneNumber,     // ← new
    String? note,
    String severity = 'normal',
  }) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.createBooking, data: {
        'provider_id':  providerId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'address':      address,
        'phone_number': phoneNumber,  // ← new
        if (note != null && note.isNotEmpty) 'note': note,
        'severity':     severity,
      });

      if (response.data['success'] == true) {
        return Right(BookingApiModel.fromJson(
            response.data['data'] as Map<String, dynamic>));
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
      final response = await _apiClient.get(
        ApiEndpoints.myBookings,
        queryParameters: {'page': page, 'size': size},
      );
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
      final response = await _apiClient.get(
        ApiEndpoints.providerBookings,
        queryParameters: {'page': page, 'size': size},
      );
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
        ApiEndpoints.bookingStatus(bookingId),
        data: {'status': status},
      );
      if (response.data['success'] == true) {
        return Right(BookingApiModel.fromJson(
            response.data['data'] as Map<String, dynamic>));
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
          await _apiClient.patch(ApiEndpoints.cancelBooking(bookingId));
      if (response.data['success'] == true) {
        return Right(BookingApiModel.fromJson(
            response.data['data'] as Map<String, dynamic>));
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
      final response =
          await _apiClient.get(ApiEndpoints.bookingById(bookingId));
      if (response.data['success'] == true) {
        return Right(BookingApiModel.fromJson(
            response.data['data'] as Map<String, dynamic>));
      }
      return Left(NetworkFailure(
          error: response.data['message'] ?? 'Booking not found'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  // ── Rate provider ────────────────────────────────────────────────────────
  Future<Either<Failure, void>> rateProvider({
    required String bookingId,
    required int rating,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.rateProvider(bookingId),   
        data: {'rating': rating},
      );
      if (response.data['success'] == true) return const Right(null);
      return Left(NetworkFailure(
          error: response.data['message'] ?? 'Failed to submit rating'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }
}