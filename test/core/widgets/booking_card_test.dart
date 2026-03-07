import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';
import 'package:sewa_hub/features/booking/presentation/state/booking_state.dart';
import 'package:sewa_hub/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:sewa_hub/core/widgets/booking_card.dart';

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

// ── Shared test data ──

final tScheduledAt = DateTime(2025, 6, 15, 10, 0);

final tPendingBooking = BookingEntity(
  id: 'abc12345678',
  userId: 'user-1',
  providerId: 'provider-1',
  scheduledAt: tScheduledAt,
  address: 'Kathmandu, Nepal',
  phoneNumber: '9841234567',
  pricePerHour: 500,
  severity: 'normal',
  effectivePricePerHour: 500,
  status: 'pending',
);

final tAcceptedBooking = BookingEntity(
  id: 'abc12345678',
  userId: 'user-1',
  providerId: 'provider-1',
  scheduledAt: tScheduledAt,
  address: 'Kathmandu, Nepal',
  phoneNumber: '9841234567',
  pricePerHour: 500,
  severity: 'urgent',
  effectivePricePerHour: 750,
  status: 'accepted',
);

final tCompletedBooking = BookingEntity(
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
);

// ── Widget builder ──

Widget createTestWidget({
  required BookingEntity booking,
  VoidCallback? onCancel,
  BookingState bookingState = const BookingState(),
}) {
  return ProviderScope(
    overrides: [
      bookingViewModelProvider.overrideWith(
        () => MockBookingViewModel(initialState: bookingState),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: BookingCard(booking: booking, onCancel: onCancel),
        ),
      ),
    ),
  );
}

void main() {
  group('BookingCard - UI Elements', () {
    // TEST 1: Address and price are displayed
    testWidgets('should display booking address and effective price',
        (tester) async {
      await tester.pumpWidget(createTestWidget(booking: tPendingBooking));
      await tester.pump();

      expect(find.text('Kathmandu, Nepal'), findsOneWidget);
      expect(find.textContaining('NPR'), findsOneWidget);
      expect(find.textContaining('500'), findsWidgets);
    });

    // TEST 2: Severity chip renders with correct label
    testWidgets('should display correct severity chip label', (tester) async {
      await tester.pumpWidget(createTestWidget(booking: tPendingBooking));
      await tester.pump();

      expect(find.text('Normal'), findsOneWidget);
    });

    // TEST 3: Urgent severity chip renders correctly
    testWidgets('should display Urgent severity chip for urgent booking',
        (tester) async {
      await tester.pumpWidget(createTestWidget(booking: tAcceptedBooking));
      await tester.pump();

      expect(find.text('Urgent'), findsOneWidget);
    });

    // TEST 4: Message button shown for accepted booking
    testWidgets('should show Message button when booking is accepted',
        (tester) async {
      await tester.pumpWidget(createTestWidget(booking: tAcceptedBooking));
      await tester.pump();

      expect(find.text('Message'), findsOneWidget);
    });

    // TEST 5: Cancel button shown for pending booking with onCancel callback
    testWidgets(
        'should show Cancel button when booking is pending and onCancel is provided',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(booking: tPendingBooking, onCancel: () {}),
      );
      await tester.pump();

      expect(find.text('Cancel'), findsOneWidget);
    });

    // TEST 6: Rate button shown for completed booking
    testWidgets('should show Rate button when booking is completed',
        (tester) async {
      await tester.pumpWidget(createTestWidget(booking: tCompletedBooking));
      await tester.pump();

      expect(find.text('Rate'), findsOneWidget);
    });

    // TEST 7: Cancel button NOT shown when onCancel is null
    testWidgets('should NOT show Cancel button when onCancel is null',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(booking: tPendingBooking, onCancel: null),
      );
      await tester.pump();

      expect(find.text('Cancel'), findsNothing);
    });
  });
}