import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';
import 'package:sewa_hub/features/notification/domain/repositories/notification_repository.dart';
import 'package:sewa_hub/features/notification/domain/usecases/get_notification_usecase.dart';

class MockNotificationRepository extends Mock
    implements INotificationRepository {}

void main() {
  late GetNotificationsUsecase usecase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    usecase = GetNotificationsUsecase(repository: mockRepository);
  });

  final tNow = DateTime(2025, 1, 1);

  final tNotification = NotificationEntity(
    id: 'notif-1',
    recipientId: 'user-1',
    type: NotificationType.bookingCreated,
    title: 'Booking Created',
    message: 'Your booking has been created.',
    isRead: false,
    createdAt: tNow,
  );

  final tReadNotification = NotificationEntity(
    id: 'notif-2',
    recipientId: 'user-1',
    type: NotificationType.bookingAccepted,
    title: 'Booking Accepted',
    message: 'Your booking has been accepted.',
    isRead: true,
    createdAt: tNow,
  );

  group('GetNotificationsUsecase', () {
    // TEST 1
    test('should return list of notifications on success', () async {
      // Arrange
      final tList = [tNotification, tReadNotification];
      when(() => mockRepository.getNotifications(page: 1, size: 20))
          .thenAnswer((_) async => Right(tList));

      // Act
      final result = await usecase(page: 1, size: 20);

      // Assert
      expect(result, Right(tList));
      verify(() => mockRepository.getNotifications(page: 1, size: 20))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    // TEST 2
    test('should return empty list when there are no notifications', () async {
      // Arrange
      when(() => mockRepository.getNotifications(page: 1, size: 20))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await usecase(page: 1, size: 20);

      // Assert
      expect(result, const Right<Failure, List<NotificationEntity>>([]));
      result.fold(
        (_) => fail('Expected Right'),
        (list) => expect(list, isEmpty),
      );
    });

    // TEST 3
    test('should return ApiFailure when server returns an error', () async {
      // Arrange
      const failure = ApiFailure(message: 'Failed to fetch notifications');
      when(() => mockRepository.getNotifications(page: 1, size: 20))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(page: 1, size: 20);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getNotifications(page: 1, size: 20))
          .called(1);
    });

    // TEST 4
    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure =
          NetworkFailure(message: 'No internet connection', error: 'Timeout');
      when(() => mockRepository.getNotifications(page: 1, size: 20))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(page: 1, size: 20);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getNotifications(page: 1, size: 20))
          .called(1);
    });

    // TEST 5
    test('should correctly pass custom page and size to repository', () async {
      // Arrange
      when(() => mockRepository.getNotifications(page: 2, size: 10))
          .thenAnswer((_) async => const Right([]));

      // Act
      await usecase(page: 2, size: 10);

      // Assert
      verify(() => mockRepository.getNotifications(page: 2, size: 10))
          .called(1);
      verifyNever(() => mockRepository.getNotifications(page: 1, size: 20));
    });

    // TEST 6
    test('should return only unread notifications when filtered', () async {
      // Arrange
      final tUnreadOnly = [tNotification]; // only unread
      when(() => mockRepository.getNotifications(page: 1, size: 20))
          .thenAnswer((_) async => Right(tUnreadOnly));

      // Act
      final result = await usecase(page: 1, size: 20);

      // Assert
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list.every((n) => !n.isRead), isTrue);
          expect(list.length, 1);
        },
      );
    });

    // TEST 7
    test('should return list with correct notification types', () async {
      // Arrange
      final tList = [tNotification, tReadNotification];
      when(() => mockRepository.getNotifications(page: 1, size: 20))
          .thenAnswer((_) async => Right(tList));

      // Act
      final result = await usecase(page: 1, size: 20);

      // Assert
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list[0].type, NotificationType.bookingCreated);
          expect(list[1].type, NotificationType.bookingAccepted);
        },
      );
    });
  });
}