import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:sewa_hub/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:sewa_hub/features/booking/domain/usecases/get_my_booking_usecase.dart';
import 'package:sewa_hub/features/booking/presentation/state/booking_state.dart';

final bookingViewModelProvider =
    NotifierProvider<BookingViewModel, BookingState>(() {
  return BookingViewModel();
});

class BookingViewModel extends Notifier<BookingState> {
  late final CreateBookingUsecase _createBookingUsecase;
  late final GetMyBookingsUsecase _getMyBookingsUsecase;
  late final CancelBookingUsecase _cancelBookingUsecase;

  @override
  BookingState build() {
    _createBookingUsecase = ref.read(createBookingUsecaseProvider);
    _getMyBookingsUsecase = ref.read(getMyBookingsUsecaseProvider);
    _cancelBookingUsecase = ref.read(cancelBookingUsecaseProvider);
    return const BookingState();
  }

  Future<void> createBooking({
    required String providerId,
    required DateTime scheduledAt,
    required String address,
    String? note,
    String severity = 'normal',
  }) async {
    state = state.copyWith(status: BookingStatus.loading);

    final params = CreateBookingParams(
      providerId: providerId,
      scheduledAt: scheduledAt,
      address: address,
      note: note,
      severity: severity,
    );

    final result = await _createBookingUsecase.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: failure.toString(),
      ),
      (booking) => state = state.copyWith(
        status: BookingStatus.success,
        booking: booking,
      ),
    );
  }

  Future<void> getMyBookings() async {
    state = state.copyWith(status: BookingStatus.loading);

    final result = await _getMyBookingsUsecase.call();

    result.fold(
      (failure) => state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: failure.toString(),
      ),
      (bookings) => state = state.copyWith(
        status: BookingStatus.listLoaded,
        bookings: bookings,
      ),
    );
  }

  Future<void> cancelBooking(String bookingId) async {
    state = state.copyWith(status: BookingStatus.loading);

    final result = await _cancelBookingUsecase.call(bookingId);

    result.fold(
      (failure) => state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: failure.toString(),
      ),
      (_) {
        // Remove from list or refresh
        state = state.copyWith(status: BookingStatus.cancelled);
        getMyBookings();
      },
    );
  }

  void reset() {
    state = const BookingState();
  }
}