import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/auth/domain/entities/auth_entity.dart';
import 'package:sewa_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:sewa_hub/features/auth/domain/usecases/register_usecase.dart';

// Mock class for IAuthRepository
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockRepository);
    // Register fallback value for AuthEntity
    registerFallbackValue(
      const AuthEntity(
        fullName: '',
        email: '',
        password: '',
      ),
    );
  });

  const tFullName = 'Test User';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  const tAuthEntity = AuthEntity(
    fullName: tFullName,
    email: tEmail,
    password: tPassword,
  );

  group('RegisterUsecase', () {
    // TEST 1 
    test('should return true when registration is successful', () async {
      // Arrange
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(
        const RegisterUsecaseParam(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
        ),
      );

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    // TEST 2 
    test('should return ApiFailure when registration fails on server',
        () async {
      // Arrange
      const failure = ApiFailure(message: 'Registration failed');
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const RegisterUsecaseParam(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any())).called(1);
    });

    // TEST 3 
    test('should return LocalDatabaseFailure when email already exists',
        () async {
      // Arrange
      const failure = LocalDatabaseFailure(
        message: 'Email already registered',
      );
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const RegisterUsecaseParam(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any())).called(1);
    });

    //  TEST 4 
    test('should create AuthEntity with correct data and pass to repository',
        () async {
      // Arrange
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      await usecase(
        const RegisterUsecaseParam(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
        ),
      );

      // Assert
      final captured = verify(
        () => mockRepository.register(captureAny()),
      ).captured;

      final capturedEntity = captured.first as AuthEntity;
      expect(capturedEntity.fullName, tFullName);
      expect(capturedEntity.email, tEmail);
      expect(capturedEntity.password, tPassword);
    });

    //TEST 5 
    test('should return NetworkFailure when there is no internet connection',
        () async {
      // Arrange
      const failure = NetworkFailure(
        message: 'No internet connection',
        error: 'Network error',
      );
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const RegisterUsecaseParam(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any())).called(1);
    });
  });

  // Additional tests for RegisterUsecaseParam
  group('RegisterUsecaseParam', () {
    test('should have correct props', () {
      // Arrange
      const params = RegisterUsecaseParam(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(params.props, [tFullName, tEmail, tPassword]);
    });

    test('two params with same values should be equal', () {
      // Arrange
      const params1 = RegisterUsecaseParam(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
      );
      const params2 = RegisterUsecaseParam(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(params1, params2);
    });

    test('two params with different values should not be equal', () {
      // Arrange
      const params1 = RegisterUsecaseParam(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
      );
      const params2 = RegisterUsecaseParam(
        fullName: 'Different User',
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(params1, isNot(params2));
    });
  });
}