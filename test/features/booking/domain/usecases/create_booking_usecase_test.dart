import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';
import 'package:sewa_hub/features/booking/domain/repositories/booking_repository.dart';
import 'package:sewa_hub/features/booking/domain/usecases/create_booking_usecase.dart';

class MockBookingRepository extends Mock implements IBookingRepository {}

void main() {
  late CreateBookingUsecase usecase;
  late MockBookingRepository mockRepository;

  setUp(() {
    mockRepository = MockBookingRepository();
    usecase = CreateBookingUsecase(repository: mockRepository);
  });

  final tScheduledAt = DateTime(2025, 6, 15, 10, 0);

  final tParamsWithDate = CreateBookingParams(
    providerId: 'provider-1',
    scheduledAt: tScheduledAt,
    address: 'Kathmandu, Nepal',
    phoneNumber: '9841234567',
    note: 'Please come early',
    severity: 'normal',
  );

  final tBookingEntity = BookingEntity(
    id: 'booking-1',
    userId: 'user-1',
    providerId: 'provider-1',
    scheduledAt: tScheduledAt,
    address: 'Kathmandu, Nepal',
    phoneNumber: '9841234567',
    note: 'Please come early',
    pricePerHour: 500,
    severity: 'normal',
    effectivePricePerHour: 500,
    status: 'pending',
  );

  group('CreateBookingUsecase', () {
    // TEST 1
    test('should return BookingEntity when booking is created successfully',
        () async {
      // Arrange
      when(
        () => mockRepository.createBooking(
          providerId: any(named: 'providerId'),
          scheduledAt: any(named: 'scheduledAt'),
          address: any(named: 'address'),
          phoneNumber: any(named: 'phoneNumber'),
          note: any(named: 'note'),
          severity: any(named: 'severity'),
        ),
      ).thenAnswer((_) async => Right(tBookingEntity));

      // Act
      final result = await usecase.call(tParamsWithDate);

      // Assert
      expect(result, Right(tBookingEntity));
      verify(
        () => mockRepository.createBooking(
          providerId: 'provider-1',
          scheduledAt: tScheduledAt,
          address: 'Kathmandu, Nepal',
          phoneNumber: '9841234567',
          note: 'Please come early',
          severity: 'normal',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    // TEST 2
    test('should return ApiFailure when server returns an error', () async {
      // Arrange
      const failure = ApiFailure(message: 'Failed to create booking');
      when(
        () => mockRepository.createBooking(
          providerId: any(named: 'providerId'),
          scheduledAt: any(named: 'scheduledAt'),
          address: any(named: 'address'),
          phoneNumber: any(named: 'phoneNumber'),
          note: any(named: 'note'),
          severity: any(named: 'severity'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.call(tParamsWithDate);

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockRepository.createBooking(
          providerId: any(named: 'providerId'),
          scheduledAt: any(named: 'scheduledAt'),
          address: any(named: 'address'),
          phoneNumber: any(named: 'phoneNumber'),
          note: any(named: 'note'),
          severity: any(named: 'severity'),
        ),
      ).called(1);
    });

    // TEST 3
    test('should return NetworkFailure when there is no internet connection',
        () async {
      // Arrange
      const failure =
          NetworkFailure(message: 'No internet connection', error: 'Timeout');
      when(
        () => mockRepository.createBooking(
          providerId: any(named: 'providerId'),
          scheduledAt: any(named: 'scheduledAt'),
          address: any(named: 'address'),
          phoneNumber: any(named: 'phoneNumber'),
          note: any(named: 'note'),
          severity: any(named: 'severity'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.call(tParamsWithDate);

      // Assert
      expect(result, const Left(failure));
    });

    // TEST 4
    test('should pass correct params including phoneNumber to repository',
        () async {
      // Arrange
      when(
        () => mockRepository.createBooking(
          providerId: any(named: 'providerId'),
          scheduledAt: any(named: 'scheduledAt'),
          address: any(named: 'address'),
          phoneNumber: any(named: 'phoneNumber'),
          note: any(named: 'note'),
          severity: any(named: 'severity'),
        ),
      ).thenAnswer((_) async => Right(tBookingEntity));

      // Act
      await usecase.call(tParamsWithDate);

      // Assert
      verify(
        () => mockRepository.createBooking(
          providerId: 'provider-1',
          scheduledAt: tScheduledAt,
          address: 'Kathmandu, Nepal',
          phoneNumber: '9841234567',
          note: 'Please come early',
          severity: 'normal',
        ),
      ).called(1);
    });

    // TEST 5
    test('should pass urgent severity correctly to repository', () async {
      // Arrange
      final urgentParams = CreateBookingParams(
        providerId: 'provider-1',
        scheduledAt: tScheduledAt,
        address: 'Kathmandu, Nepal',
        phoneNumber: '9841234567',
        severity: 'urgent',
      );
      when(
        () => mockRepository.createBooking(
          providerId: any(named: 'providerId'),
          scheduledAt: any(named: 'scheduledAt'),
          address: any(named: 'address'),
          phoneNumber: any(named: 'phoneNumber'),
          note: any(named: 'note'),
          severity: any(named: 'severity'),
        ),
      ).thenAnswer((_) async => Right(tBookingEntity));

      // Act
      await usecase.call(urgentParams);

      // Assert
      verify(
        () => mockRepository.createBooking(
          providerId: any(named: 'providerId'),
          scheduledAt: any(named: 'scheduledAt'),
          address: any(named: 'address'),
          phoneNumber: any(named: 'phoneNumber'),
          note: any(named: 'note'),
          severity: 'urgent',
        ),
      ).called(1);
    });

    // TEST 6
    test('should handle null note and pass it to repository', () async {
      // Arrange
      final noNoteParams = CreateBookingParams(
        providerId: 'provider-1',
        scheduledAt: tScheduledAt,
        address: 'Kathmandu, Nepal',
        phoneNumber: '9841234567',
        note: null,
        severity: 'normal',
      );
      when(
        () => mockRepository.createBooking(
          providerId: any(named: 'providerId'),
          scheduledAt: any(named: 'scheduledAt'),
          address: any(named: 'address'),
          phoneNumber: any(named: 'phoneNumber'),
          note: any(named: 'note'),
          severity: any(named: 'severity'),
        ),
      ).thenAnswer((_) async => Right(tBookingEntity));

      // Act
      final result = await usecase.call(noNoteParams);

      // Assert
      expect(result, Right(tBookingEntity));
      verify(
        () => mockRepository.createBooking(
          providerId: any(named: 'providerId'),
          scheduledAt: any(named: 'scheduledAt'),
          address: any(named: 'address'),
          phoneNumber: any(named: 'phoneNumber'),
          note: null,
          severity: any(named: 'severity'),
        ),
      ).called(1);
    });

    // TEST 7
    test('CreateBookingParams props should be equal for same values', () {
      // Arrange
      final params1 = CreateBookingParams(
        providerId: 'provider-1',
        scheduledAt: tScheduledAt,
        address: 'Kathmandu, Nepal',
        phoneNumber: '9841234567',
        note: 'Note',
        severity: 'normal',
      );
      final params2 = CreateBookingParams(
        providerId: 'provider-1',
        scheduledAt: tScheduledAt,
        address: 'Kathmandu, Nepal',
        phoneNumber: '9841234567',
        note: 'Note',
        severity: 'normal',
      );

      // Assert
      expect(params1, params2);
    });
  });
}