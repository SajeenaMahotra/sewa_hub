// import 'package:dartz/dartz.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sewa_hub/core/error/failures.dart';
// import 'package:sewa_hub/core/usecases/app_usecase.dart';
// import 'package:sewa_hub/features/booking/data/repositories/booking_repository.dart';
// import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';
// import 'package:sewa_hub/features/booking/domain/repositories/booking_repository.dart';

// final getMyBookingsUsecaseProvider = Provider<GetMyBookingsUsecase>((ref) {
//   return GetMyBookingsUsecase(
//     repository: ref.watch(bookingRepositoryProvider),
//   );
// });

// class GetMyBookingsUsecase
//     implements UsecaseWithoutParams<List<BookingEntity>> {
//   final IBookingRepository _repository;

//   GetMyBookingsUsecase({required IBookingRepository repository})
//       : _repository = repository;

//   @override
//   Future<Either<Failure, List<BookingEntity>>> call() {
//     return _repository.getMyBookings();
//   }
// }