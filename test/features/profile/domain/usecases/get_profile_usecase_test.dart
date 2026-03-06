import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';
import 'package:sewa_hub/features/profile/domain/repositories/profile_repository.dart';
import 'package:sewa_hub/features/profile/domain/usecases/get_profile_usecase.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late GetProfileUsecase usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = GetProfileUsecase(profileRepository: mockRepository);
  });

  const tProfileEntity = ProfileEntity(
    fullName: 'John Doe',
    email: 'johndoe@gmail.com',
    profilePicture: 'https://example.com/profile.jpg',
  );

  group('GetProfileUsecase', () {
    // TEST 1
    test('should return ProfileEntity when get profile is successful', () async {
      // Arrange
      when(() => mockRepository.getProfile())
          .thenAnswer((_) async => const Right(tProfileEntity));

      // Act
      final result = await usecase.call();

      // Assert
      expect(result, const Right(tProfileEntity));
      verify(() => mockRepository.getProfile()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    // TEST 2
    test('should return ApiFailure when server returns an error', () async {
      // Arrange
      const failure = ApiFailure(message: 'Failed to fetch profile');
      when(() => mockRepository.getProfile())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.call();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getProfile()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    // TEST 3
    test('should return NetworkFailure when there is no internet connection',
        () async {
      // Arrange
      const failure =
          NetworkFailure(message: 'No internet connection', error: 'Network error');
      when(() => mockRepository.getProfile())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.call();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getProfile()).called(1);
    });

    // TEST 4
    test('should return ProfileEntity with null profilePicture', () async {
      // Arrange
      const tProfileNoImage = ProfileEntity(
        fullName: 'John Doe',
        email: 'johndoe@gmail.com',
        profilePicture: null,
      );
      when(() => mockRepository.getProfile())
          .thenAnswer((_) async => const Right(tProfileNoImage));

      // Act
      final result = await usecase.call();

      // Assert
      expect(result, const Right(tProfileNoImage));
      result.fold(
        (_) => fail('Expected Right'),
        (entity) => expect(entity.profilePicture, isNull),
      );
    });

    // TEST 5
    test('should return LocalDatabaseFailure when local cache read fails',
        () async {
      // Arrange
      const failure = LocalDatabaseFailure(message: 'Cache read error');
      when(() => mockRepository.getProfile())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.call();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getProfile()).called(1);
    });

    // TEST 6
    test('should call repository exactly once per usecase call', () async {
      // Arrange
      when(() => mockRepository.getProfile())
          .thenAnswer((_) async => const Right(tProfileEntity));

      // Act
      await usecase.call();
      await usecase.call();

      // Assert
      verify(() => mockRepository.getProfile()).called(2);
    });
  });
}