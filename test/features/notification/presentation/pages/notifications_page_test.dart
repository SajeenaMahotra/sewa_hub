import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';
import 'package:sewa_hub/features/notification/presentation/pages/notifications_page.dart';
import 'package:sewa_hub/features/notification/presentation/state/notification_state.dart';
import 'package:sewa_hub/features/notification/presentation/view_model/notification_view_model.dart';

// ── Mock ViewModel ──

class MockNotificationViewModel extends Notifier<NotificationState>
    implements NotificationViewModel {
  final NotificationState _initialState;

  MockNotificationViewModel({
    NotificationState initialState = const NotificationState(),
  }) : _initialState = initialState;

  @override
  NotificationState build() => _initialState;

  @override
  Future<void> fetchNotifications() async {}

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> markOneRead(String id) async {}

  @override
  Future<void> deleteAll() async {}
}

// ── Test Widget Builder ──

final tNow = DateTime(2025, 1, 1);

final tNotifications = [
  NotificationEntity(
    id: 'notif-1',
    recipientId: 'user-1',
    type: NotificationType.bookingCreated,
    title: 'Booking Created',
    message: 'Your booking has been created.',
    isRead: false,
    createdAt: tNow,
  ),
  NotificationEntity(
    id: 'notif-2',
    recipientId: 'user-1',
    type: NotificationType.bookingAccepted,
    title: 'Booking Accepted',
    message: 'Your booking has been accepted.',
    isRead: true,
    createdAt: tNow,
  ),
];

Widget createTestWidget({
  NotificationState state = const NotificationState(),
}) {
  return ProviderScope(
    overrides: [
      notificationViewModelProvider.overrideWith(
        () => MockNotificationViewModel(initialState: state),
      ),
    ],
    child: const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(800, 1200)),
        child: NotificationsPage(),
      ),
    ),
  );
}

void main() {
  group('NotificationsPage - UI Elements', () {
    // TEST 1: AppBar title is displayed
    testWidgets('should display Notifications title in AppBar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    // TEST 2: Loading state shows CircularProgressIndicator
    testWidgets('should show loading indicator when status is loading',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        state: const NotificationState(status: NotificationStatus.loading),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // TEST 3: Empty state shows correct icon and message
    testWidgets('should show empty state when notifications list is empty',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        state: const NotificationState(
          status: NotificationStatus.loaded,
          notifications: [],
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
      expect(find.text('No notifications yet'), findsOneWidget);
    });

    // TEST 4: Error state shows error message and Retry button
    testWidgets('should show error message and Retry button on error',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        state: const NotificationState(
          status: NotificationStatus.error,
          errorMessage: 'Something went wrong',
        ),
      ));
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
    });

    // TEST 5: Loaded state renders notification list
    testWidgets('should display notification tiles when loaded', (tester) async {
      await tester.pumpWidget(createTestWidget(
        state: NotificationState(
          status: NotificationStatus.loaded,
          notifications: tNotifications,
          unreadCount: 1,
        ),
      ));
      await tester.pump();

      expect(find.text('Booking Created'), findsOneWidget);
      expect(find.text('Booking Accepted'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    // TEST 6: "Mark all read" button visible when unreadCount > 0
    testWidgets('should show Mark all read button when there are unread notifications',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        state: NotificationState(
          status: NotificationStatus.loaded,
          notifications: tNotifications,
          unreadCount: 1,
        ),
      ));
      await tester.pump();

      expect(find.text('Mark all read'), findsOneWidget);
    });

    // TEST 7: Delete all icon button visible when notifications exist, tapping shows confirm dialog
    testWidgets(
        'should show delete icon and confirmation dialog on tap', (tester) async {
      await tester.pumpWidget(createTestWidget(
        state: NotificationState(
          status: NotificationStatus.loaded,
          notifications: tNotifications,
          unreadCount: 1,
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Clear all notifications?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}