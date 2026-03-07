import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';
import 'package:sewa_hub/features/booking/presentation/pages/booking_detail_page.dart';
import 'package:sewa_hub/features/booking/presentation/state/booking_state.dart';
import 'package:sewa_hub/features/booking/presentation/view_model/booking_view_model.dart';

// ── Mock ViewModel ──

class MockBookingViewModel extends Notifier<BookingState>
    implements BookingViewModel {
  final BookingState _initialState;

  MockBookingViewModel({BookingState initialState = const BookingState()})
      : _initialState = initialState;

  @override
  BookingState build() => _initialState;

  @override
  Future<void> createBooking({
    required String providerId,
    required DateTime scheduledAt,
    required String address,
    required String phoneNumber,
    String? note,
    String severity = 'normal',
  }) async {}

  @override
  Future<void> getMyBookings() async {}

  @override
  Future<void> cancelBooking(String bookingId) async {}

  @override
  Future<void> rateProvider({
    required String bookingId,
    required int rating,
  }) async {}

  @override
  void reset() {}
}

// ── Shared test booking entities ──

final tScheduledAt = DateTime(2025, 6, 15, 10, 0);
final tCreatedAt = DateTime(2025, 6, 10, 8, 0);

final tPendingBooking = BookingEntity(
  id: 'abc12345678',
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
  createdAt: tCreatedAt,
  provider: null,
);

// ── Widget builder ──

Widget createTestWidget({
  required BookingEntity booking,
  BookingState bookingState = const BookingState(),
}) {
  return ProviderScope(
    overrides: [
      bookingViewModelProvider.overrideWith(
        () => MockBookingViewModel(initialState: bookingState),
      ),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(800, 1200)),
        child: BookingDetailPage(booking: booking),
      ),
    ),
  );
}

void main() {
  group('BookingDetailPage - UI Elements', () {
    // TEST 1: AppBar title and status badge are shown
    testWidgets('should display Booking Details title and status badge',
        (tester) async {
      await tester.pumpWidget(createTestWidget(booking: tPendingBooking));
      await tester.pump();

      expect(find.text('Booking Details'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    // TEST 2: Booking address is displayed
    testWidgets('should display the booking address', (tester) async {
      await tester.pumpWidget(createTestWidget(booking: tPendingBooking));
      await tester.pump();

      expect(find.text('Kathmandu, Nepal'), findsOneWidget);
    });

    // TEST 3: Price breakdown section is displayed
    testWidgets('should display Price Breakdown section', (tester) async {
      await tester.pumpWidget(createTestWidget(booking: tPendingBooking));
      await tester.pump();

      expect(find.text('Price Breakdown'), findsOneWidget);
      expect(find.textContaining('NPR'), findsWidgets);
    });

    // TEST 4: Status timeline is shown with Booking Status label
    testWidgets('should display the status timeline', (tester) async {
      await tester.pumpWidget(createTestWidget(booking: tPendingBooking));
      await tester.pump();

      expect(find.text('Booking Status'), findsOneWidget);
      expect(find.text('Pending'), findsWidgets);
    });

    // TEST 5: Cancel button visible when booking status is pending
    testWidgets('should show Cancel Booking button when status is pending',
        (tester) async {
      await tester.pumpWidget(createTestWidget(booking: tPendingBooking));
      await tester.pump();

      expect(find.text('Cancel Booking'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Cancel Booking'),
        findsOneWidget,
      );
    });

    // TEST 6: Cancel button NOT shown when booking is not pending
    testWidgets(
        'should NOT show Cancel Booking button when status is completed',
        (tester) async {
      final completedBooking = BookingEntity(
        id: 'abc12345678',
        userId: 'user-1',
        providerId: 'provider-1',
        scheduledAt: tScheduledAt,
        address: 'Kathmandu, Nepal',
        phoneNumber: '9841234567',
        pricePerHour: 500,
        severity: 'normal',
        effectivePricePerHour: 500,
        status: 'completed',
        createdAt: tCreatedAt,
      );

      await tester.pumpWidget(createTestWidget(booking: completedBooking));
      await tester.pump();

      expect(find.text('Cancel Booking'), findsNothing);
    });

    // TEST 7: Tapping Cancel Booking shows confirmation dialog
    testWidgets('should show confirmation dialog when Cancel Booking tapped',
        (tester) async {
      await tester.pumpWidget(createTestWidget(booking: tPendingBooking));
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel Booking'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Booking'), findsWidgets);
      expect(
        find.text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.text('Keep it'), findsOneWidget);
    });
  });
}