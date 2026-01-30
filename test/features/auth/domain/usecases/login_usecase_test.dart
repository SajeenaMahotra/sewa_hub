import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/auth/domain/entities/auth_entity.dart';
import 'package:sewa_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:sewa_hub/features/auth/domain/usecases/login_usecase.dart';

// Mock class for IAuthRepository
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  const tAuthEntity = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: tEmail,
    password: tPassword,
    profilePicture: 'https://example.com/profile.jpg',
  );

  group('LoginUsecase', () {
    // TEST 1
    test('should return AuthEntity when login is successful', () async {
      // Arrange
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await usecase(
        const LoginUsecaseParam(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Right(tAuthEntity));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    // TEST 2 
    test('should return ApiFailure when login fails with invalid credentials',
        () async {
      // Arrange
      const failure = ApiFailure(message: 'Invalid credentials');
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const LoginUsecaseParam(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    //TEST 3 
    test('should return NetworkFailure when there is no internet connection',
        () async {
      // Arrange
      const failure = NetworkFailure(message: 'No internet connection', error: 'Network error');
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const LoginUsecaseParam(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });

    // TEST 4 
    test('should pass correct email and password to repository', () async {
      // Arrange
      when(
        () => mockRepository.login(any(), any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      await usecase(
        const LoginUsecaseParam(email: tEmail, password: tPassword),
      );

      // Assert
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });

    // TEST 5 
    test('should return LocalDatabaseFailure when offline login fails',
        () async {
      // Arrange
      const failure = LocalDatabaseFailure(
        message: 'Invalid email or password',
      );
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const LoginUsecaseParam(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });
  });

  // Additional tests for LoginUsecaseParam
  group('LoginUsecaseParam', () {
    test('should have correct props', () {
      // Arrange
      const params = LoginUsecaseParam(email: tEmail, password: tPassword);

      // Assert
      expect(params.props, [tEmail, tPassword]);
    });

    test('two params with same values should be equal', () {
      // Arrange
      const params1 = LoginUsecaseParam(email: tEmail, password: tPassword);
      const params2 = LoginUsecaseParam(email: tEmail, password: tPassword);

      // Assert
      expect(params1, params2);
    });

    test('two params with different values should not be equal', () {
      // Arrange
      const params1 = LoginUsecaseParam(email: tEmail, password: tPassword);
      const params2 = LoginUsecaseParam(
        email: 'other@email.com',
        password: tPassword,
      );

      // Assert
      expect(params1, isNot(params2));
    });
  });
}