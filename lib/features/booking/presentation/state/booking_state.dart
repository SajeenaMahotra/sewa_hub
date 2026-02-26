import 'package:equatable/equatable.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';

enum BookingStatus {
  initial,
  loading,
  success,
  listLoaded,
  cancelled,
  error,
}

class BookingState extends Equatable {
  final BookingStatus status;
  final BookingEntity? booking;
  final List<BookingEntity> bookings;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStatus.initial,
    this.booking,
    this.bookings = const [],
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStatus? status,
    BookingEntity? booking,
    List<BookingEntity>? bookings,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      booking: booking ?? this.booking,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, booking, bookings, errorMessage];
}