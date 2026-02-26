import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/widgets/dotted_background.dart';
import 'package:sewa_hub/features/booking/presentation/state/booking_state.dart';
import 'package:sewa_hub/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:sewa_hub/core/widgets/booking_card.dart';

class MyBookingsPage extends ConsumerStatefulWidget {
  const MyBookingsPage({super.key});

  @override
  ConsumerState<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends ConsumerState<MyBookingsPage> {
  static const _orange = Color(0xFFFF6B35);
  static const _textPrimary = Color(0xFF0F172A);
  static const _divider = Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingViewModelProvider.notifier).getMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _divider),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: _textPrimary, size: 22),
            onPressed: () =>
                ref.read(bookingViewModelProvider.notifier).getMyBookings(),
          ),
        ],
      ),
      body: DottedBackground(
        child: () {
          if (state.status == BookingStatus.loading &&
              state.bookings.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: _orange));
          }

          if (state.status == BookingStatus.error &&
              state.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  Text(state.errorMessage ?? 'Something went wrong',
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 14)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => ref
                        .read(bookingViewModelProvider.notifier)
                        .getMyBookings(),
                    child: const Text('Try again',
                        style: TextStyle(color: _orange)),
                  )
                ],
              ),
            );
          }

          if (state.bookings.isEmpty) {
            return _EmptyState();
          }

          return RefreshIndicator(
            color: _orange,
            onRefresh: () =>
                ref.read(bookingViewModelProvider.notifier).getMyBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return BookingCard(
                  booking: booking,
                  onCancel: booking.status == 'pending'
                      ? () => _confirmCancel(booking.id!)
                      : null,
                );
              },
            ),
          );
        }(),
      ),
    );
  }

  void _confirmCancel(String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking',
            style:
                TextStyle(fontWeight: FontWeight.w700, color: _textPrimary)),
        content: const Text(
            'Are you sure you want to cancel this booking?',
            style: TextStyle(color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(bookingViewModelProvider.notifier)
                  .cancelBooking(bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFDDCC), width: 2),
            ),
            child: const Icon(Icons.calendar_today_outlined,
                size: 36, color: Color(0xFFFF6B35)),
          ),
          const SizedBox(height: 20),
          const Text('No bookings yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          const Text('Your booking history will appear here',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}