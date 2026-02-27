import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/widgets/dotted_background.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';
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

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  static const _filters = [
    {'value': 'all',       'label': 'All'},
    {'value': 'pending',   'label': 'Pending'},
    {'value': 'accepted',  'label': 'Accepted'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'rejected',  'label': 'Rejected'},
    {'value': 'cancelled', 'label': 'Cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingViewModelProvider.notifier).getMyBookings();
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _providerName(BookingEntity b) {
    if (b.provider is Map) {
      final user = (b.provider as Map)['Useruser_id'];
      if (user is Map) return user['fullname']?.toString().toLowerCase() ?? '';
    }
    return '';
  }

  List<BookingEntity> _applyFilters(List<BookingEntity> bookings) {
    return bookings.where((b) {
      final matchesFilter =
          _selectedFilter == 'all' || b.status == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          _providerName(b).contains(_searchQuery) ||
          b.address.toLowerCase().contains(_searchQuery);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Color _filterColor(String value) {
    switch (value) {
      case 'pending':   return const Color(0xFFF59E0B);
      case 'accepted':  return const Color(0xFF22C55E);
      case 'completed': return const Color(0xFF3B82F6);
      case 'rejected':  return const Color(0xFFEF4444);
      case 'cancelled': return const Color(0xFF94A3B8);
      default:          return _orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingViewModelProvider);
    final filtered = _applyFilters(state.bookings);

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
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // ── Search bar ─────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14, color: _textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search provider or address...',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 18, color: Color(0xFF94A3B8)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Icon(Icons.close_rounded,
                                  size: 16, color: Color(0xFF94A3B8)),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // ── Filter chips ───────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _filters.map((f) {
                      final value = f['value']!;
                      final label = f['label']!;
                      final isSelected = _selectedFilter == value;
                      final color = _filterColor(value);
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedFilter = value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.12)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? color
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Container(height: 1, color: _divider),

              // ── Results count ──────────────────────────────────────
              if (state.bookings.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        '${filtered.length} booking${filtered.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── List ──────────────────────────────────────────────
              Expanded(
                child: state.bookings.isEmpty
                    ? _EmptyState()
                    : filtered.isEmpty
                        ? _NoResults(
                            hasSearch: _searchQuery.isNotEmpty,
                            hasFilter: _selectedFilter != 'all',
                            onClear: () => setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _selectedFilter = 'all';
                            }),
                          )
                        : RefreshIndicator(
                            color: _orange,
                            onRefresh: () => ref
                                .read(bookingViewModelProvider.notifier)
                                .getMyBookings(),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 12, 16, 24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final booking = filtered[index];
                                return BookingCard(
                                  booking: booking,
                                  onCancel: booking.status == 'pending'
                                      ? () =>
                                          _confirmCancel(booking.id!)
                                      : null,
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        }(),
      ),
    );
  }

  void _confirmCancel(String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: _textPrimary)),
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

// ── No Results ─────────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  final bool hasSearch;
  final bool hasFilter;
  final VoidCallback onClear;

  const _NoResults({
    required this.hasSearch,
    required this.hasFilter,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 36, color: Color(0xFFFF6B35)),
          ),
          const SizedBox(height: 16),
          const Text('No bookings found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text(
            hasSearch && hasFilter
                ? 'Try a different search or filter'
                : hasSearch
                    ? 'No results for your search'
                    : 'No bookings with this status',
            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onClear,
            child: const Text('Clear filters',
                style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

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