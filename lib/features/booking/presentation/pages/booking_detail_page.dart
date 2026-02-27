import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/core/widgets/dotted_background.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';
import 'package:sewa_hub/features/booking/presentation/state/booking_state.dart';
import 'package:sewa_hub/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:sewa_hub/features/booking/presentation/widgets/booking_status_badge.dart';
import 'package:sewa_hub/features/booking/presentation/widgets/severity_selector.dart';

class BookingDetailPage extends ConsumerWidget {
  final BookingEntity booking;

  const BookingDetailPage({super.key, required this.booking});

  static const _orange = Color(0xFFFF6B35);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _divider = Color(0xFFF1F5F9);
  static const _red = Color(0xFFEF4444);

  //  Helpers

  String get _providerName {
    if (booking.provider is Map) {
      final user = (booking.provider as Map)['Useruser_id'];
      if (user is Map) return user['fullname']?.toString() ?? 'Provider';
    }
    return 'Provider';
  }

  String get _providerCategory {
    if (booking.provider is Map) {
      final cat = (booking.provider as Map)['ServiceCategorycatgeory_id'];
      if (cat is Map) return cat['categoryName']?.toString() ?? '';
    }
    return '';
  }

  String get _providerImage {
    if (booking.provider is Map) {
      final user = (booking.provider as Map)['Useruser_id'];
      if (user is Map) {
        final img = user['imageUrl']?.toString() ?? '';
        if (img.isEmpty) return '';
        if (img.startsWith('http')) return img;
        return 'http://10.0.2.2:5050$img';
      }
    }
    return '';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  double get _multiplier =>
      kSeverityOptions
          .firstWhere((o) => o.value == booking.severity,
              orElse: () => kSeverityOptions.first)
          .multiplier;

  Color get _severityColor =>
      kSeverityOptions
          .firstWhere((o) => o.value == booking.severity,
              orElse: () => kSeverityOptions.first)
          .color;

  bool get _canCancel => booking.status == 'pending';

  //  Build 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingViewModelProvider);

    ref.listen<BookingState>(bookingViewModelProvider, (_, next) {
      if (next.status == BookingStatus.cancelled) {
        SnackbarUtils.showSuccess(context, message: 'Booking cancelled');
        Navigator.pop(context);
      }
      if (next.status == BookingStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, message: next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BookingStatusBadge(status: booking.status),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _divider),
        ),
      ),
      body: DottedBackground(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                child: Column(
                  children: [
                    // ── Main Card ───────────────────────
                    _DetailCard(
                      child: Column(
                        children: [
                          // Gradient bar
                          Container(
                            height: 5,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [_orange, Color(0xFFFF9A6C)]),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                          ),

                          // Provider hero
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                _Avatar(
                                  imageUrl: _providerImage,
                                  initials: _initials(_providerName),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _providerName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: _textPrimary,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      if (_providerCategory.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          _providerCategory,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: _orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _HDivider(),

                          // Booking details
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _DetailRow(
                                  icon: Icons.confirmation_number_outlined,
                                  iconBg: const Color(0xFFF0F9FF),
                                  iconColor: const Color(0xFF0EA5E9),
                                  label: 'Booking ID',
                                  value: booking.id != null
                                      ? '#${booking.id!.substring(booking.id!.length - 8).toUpperCase()}'
                                      : '—',
                                  isMonospace: true,
                                ),
                                const SizedBox(height: 14),
                                _DetailRow(
                                  icon: Icons.calendar_today_outlined,
                                  iconBg: const Color(0xFFFFF0F0),
                                  iconColor: const Color(0xFFEF4444),
                                  label: 'Scheduled Date',
                                  value: DateFormat('EEEE, MMMM d yyyy')
                                      .format(booking.scheduledAt),
                                  subValue: DateFormat('h:mm a')
                                      .format(booking.scheduledAt),
                                ),
                                const SizedBox(height: 14),
                                _DetailRow(
                                  icon: Icons.location_on_outlined,
                                  iconBg: const Color(0xFFFFF7ED),
                                  iconColor: _orange,
                                  label: 'Service Address',
                                  value: booking.address,
                                ),
                                if (booking.note != null &&
                                    booking.note!.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  _DetailRow(
                                    icon: Icons.notes_rounded,
                                    iconBg: const Color(0xFFF8FAFC),
                                    iconColor: _textSecondary,
                                    label: 'Note',
                                    value: booking.note!,
                                  ),
                                ],
                                const SizedBox(height: 14),
                                _DetailRow(
                                  icon: kSeverityOptions
                                      .firstWhere(
                                          (o) => o.value == booking.severity,
                                          orElse: () => kSeverityOptions.first)
                                      .icon,
                                  iconBg: _severityColor.withOpacity(0.1),
                                  iconColor: _severityColor,
                                  label: 'Urgency Level',
                                  value: booking.severity[0].toUpperCase() +
                                      booking.severity.substring(1),
                                  valueColor: _severityColor,
                                ),
                                if (booking.createdAt != null) ...[
                                  const SizedBox(height: 14),
                                  _DetailRow(
                                    icon: Icons.access_time_rounded,
                                    iconBg: const Color(0xFFF8FAFC),
                                    iconColor: _textSecondary,
                                    label: 'Booked On',
                                    value: DateFormat('MMM d, yyyy • h:mm a')
                                        .format(booking.createdAt!),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          _HDivider(),

                          // Price breakdown
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Price Breakdown',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _PriceRow(
                                  label: 'Base rate',
                                  value:
                                      'NPR ${booking.pricePerHour.toStringAsFixed(0)}/hr',
                                ),
                                const SizedBox(height: 8),
                                _PriceRow(
                                  label: 'Urgency multiplier (×$_multiplier)',
                                  value: booking.severity == 'normal'
                                      ? 'No extra charge'
                                      : '+${((_multiplier - 1) * 100).toStringAsFixed(0)}%',
                                  valueColor: booking.severity == 'normal'
                                      ? const Color(0xFF22C55E)
                                      : _severityColor,
                                ),
                                const SizedBox(height: 12),
                                Container(height: 1, color: _divider),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Effective rate',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'NPR ${booking.effectivePricePerHour.toStringAsFixed(0)}/hr',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: _orange,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Status Timeline ─────────────────
                    const SizedBox(height: 16),
                    _StatusTimeline(currentStatus: booking.status),
                  ],
                ),
              ),
            ),

            // ── Bottom Actions ────────────────────────
            if (_canCancel)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: state.status == BookingStatus.loading
                          ? null
                          : () => _confirmCancel(context, ref),
                      icon: state.status == BookingStatus.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.cancel_outlined, size: 20),
                      label: Text(
                        state.status == BookingStatus.loading
                            ? 'Cancelling...'
                            : 'Cancel Booking',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _red.withOpacity(0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking',
            style: TextStyle(fontWeight: FontWeight.w700, color: _textPrimary)),
        content: const Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
            style: TextStyle(color: _textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep it',
                style: TextStyle(color: _textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(bookingViewModelProvider.notifier)
                  .cancelBooking(booking.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
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

//  Status Timeline 
class _StatusTimeline extends StatelessWidget {
  final String currentStatus;

  const _StatusTimeline({required this.currentStatus});

  static const _steps = [
    {'key': 'pending', 'label': 'Pending', 'icon': Icons.hourglass_empty_rounded},
    {'key': 'accepted', 'label': 'Accepted', 'icon': Icons.check_circle_outline_rounded},
    {'key': 'completed', 'label': 'Completed', 'icon': Icons.task_alt_rounded},
  ];

  static const _cancelledSteps = [
    {'key': 'pending', 'label': 'Pending', 'icon': Icons.hourglass_empty_rounded},
    {'key': 'cancelled', 'label': 'Cancelled', 'icon': Icons.cancel_outlined},
  ];

  static const _rejectedSteps = [
    {'key': 'pending', 'label': 'Pending', 'icon': Icons.hourglass_empty_rounded},
    {'key': 'rejected', 'label': 'Rejected', 'icon': Icons.cancel_outlined},
  ];

  List<Map<String, dynamic>> get _activeSteps {
    if (currentStatus == 'cancelled') return _cancelledSteps.cast();
    if (currentStatus == 'rejected') return _rejectedSteps.cast();
    return _steps.cast();
  }

  Color _stepColor(String stepKey) {
    if (stepKey == 'cancelled' || stepKey == 'rejected') {
      return const Color(0xFFEF4444);
    }
    final order = ['pending', 'accepted', 'completed'];
    final currentIdx = order.indexOf(currentStatus);
    final stepIdx = order.indexOf(stepKey);
    if (stepIdx <= currentIdx) return const Color(0xFFFF6B35);
    return const Color(0xFFE2E8F0);
  }

  bool _isActive(String stepKey) {
    final order = ['pending', 'accepted', 'completed'];
    final currentIdx = order.indexOf(currentStatus);
    final stepIdx = order.indexOf(stepKey);
    if (currentStatus == 'cancelled' || currentStatus == 'rejected') {
      return stepKey == currentStatus || stepKey == 'pending';
    }
    return stepIdx <= currentIdx;
  }

  @override
  Widget build(BuildContext context) {
    final steps = _activeSteps;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Status',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isEven) {
                final step = steps[i ~/ 2];
                final active = _isActive(step['key'] as String);
                final color = _stepColor(step['key'] as String);
                return Expanded(
                  flex: 0,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: active
                              ? color.withOpacity(0.1)
                              : const Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: active ? color : const Color(0xFFE2E8F0),
                              width: 2),
                        ),
                        child: Icon(
                          step['icon'] as IconData,
                          size: 18,
                          color:
                              active ? color : const Color(0xFFCBD5E1),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: active ? color : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Connector line
                final leftStep = steps[i ~/ 2];
                final leftActive = _isActive(leftStep['key'] as String);
                final rightStep = steps[(i ~/ 2) + 1];
                final rightActive = _isActive(rightStep['key'] as String);
                final lineActive = leftActive && rightActive;
                return Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 24),
                    color: lineActive
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFFE2E8F0),
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}

//  Shared Sub-widgets 

class _DetailCard extends StatelessWidget {
  final Widget child;
  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 3))
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}

class _HDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: const Color(0xFFF1F5F9));
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final String initials;

  const _Avatar({required this.imageUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFFFF3EE),
        border: Border.all(color: const Color(0xFFFFDDCC), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? Image.network(imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _InitialsText(initials))
          : _InitialsText(initials),
    );
  }
}

class _InitialsText extends StatelessWidget {
  final String initials;
  const _InitialsText(this.initials);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(initials,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFF6B35))),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final String? subValue;
  final Color? valueColor;
  final bool isMonospace;

  const _DetailRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subValue,
    this.valueColor,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6)),
              const SizedBox(height: 3),
              Text(value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF0F172A),
                    fontFamily: isMonospace ? 'monospace' : null,
                  )),
              if (subValue != null) ...[
                const SizedBox(height: 2),
                Text(subValue!,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF64748B))),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PriceRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF64748B))),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF0F172A))),
      ],
    );
  }
}