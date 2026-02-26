import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/booking/data/repositories/booking_repository.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';
import 'package:sewa_hub/features/booking/domain/repositories/booking_repository.dart';

final cancelBookingUsecaseProvider = Provider<CancelBookingUsecase>((ref) {
  return CancelBookingUsecase(
    repository: ref.watch(bookingRepositoryProvider),
  );
});

class CancelBookingUsecase
    implements UsecaseWithParams<BookingEntity, String> {
  final IBookingRepository _repository;

  CancelBookingUsecase({required IBookingRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, BookingEntity>> call(String bookingId) {
    return _repository.cancelBooking(bookingId);
  }
}