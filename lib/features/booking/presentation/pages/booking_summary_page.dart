import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/core/widgets/dotted_background.dart';
import 'package:sewa_hub/features/booking/presentation/state/booking_state.dart';
import 'package:sewa_hub/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:sewa_hub/features/booking/presentation/widgets/severity_selector.dart';
import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';

class BookingSummaryPage extends ConsumerWidget {
  final ProviderEntity provider;
  final DateTime scheduledAt;
  final String address;
  final String phoneNumber;    // ← proper field, not just a constructor param
  final String? note;
  final String severity;

  const BookingSummaryPage({
    super.key,
    required this.provider,
    required this.scheduledAt,
    required this.address,
    required this.phoneNumber, // ← named, required
    this.note,
    required this.severity,
  });

  static const _orange        = Color(0xFFFF6B35);
  static const _textPrimary   = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _divider       = Color(0xFFF1F5F9);
  static const _green         = Color(0xFF22C55E);

  String _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'http://10.0.2.2:5050$path';
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  double get _multiplier =>
      kSeverityOptions.firstWhere((o) => o.value == severity).multiplier;

  double get _effectivePrice => provider.pricePerHour * _multiplier;

  Color get _severityColor =>
      kSeverityOptions.firstWhere((o) => o.value == severity).color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(bookingViewModelProvider);
    final name     = provider.user?.fullname ?? 'Provider';
    final imageUrl = _resolveImageUrl(
        provider.imageUrl ?? provider.user?.imageUrl);

    ref.listen<BookingState>(bookingViewModelProvider, (_, next) {
      if (next.status == BookingStatus.success) {
        SnackbarUtils.showSuccess(context,
            message: 'Booking request sent successfully!');
        int popCount = 0;
Navigator.of(context).popUntil((_) => popCount++ >= 2);
        ref.read(bookingViewModelProvider.notifier).reset();
      }
      if (next.status == BookingStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, message: next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor:        Colors.white,
        elevation:              0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Booking Summary',
            style: TextStyle(
              color: _textPrimary, fontWeight: FontWeight.w800,
              fontSize: 18, letterSpacing: -0.3,
            )),
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
                    // ── Review banner ───────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FFF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: const BoxDecoration(
                              color: Color(0xFFDCFCE7),
                              shape: BoxShape.circle),
                          child: const Icon(
                              Icons.check_circle_outline_rounded,
                              color: _green, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Review your booking',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF15803D))),
                              SizedBox(height: 2),
                              Text(
                                  'Please confirm all details before submitting',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF16A34A))),
                            ],
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 16),

                    // ── Summary card ────────────────────────────────────
                    _SummaryCard(
                      child: Column(
                        children: [
                          Container(
                            height: 5,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [_orange, Color(0xFFFF9A6C)]),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                          ),

                          // Provider row
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFFFFF3EE),
                                  border: Border.all(
                                      color: const Color(0xFFFFDDCC),
                                      width: 2),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: imageUrl.isNotEmpty
                                    ? Image.network(imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _InitialsWidget(
                                                initials: _initials(name)))
                                    : _InitialsWidget(
                                        initials: _initials(name)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: _textPrimary,
                                            letterSpacing: -0.3)),
                                    if (provider.category != null) ...[
                                      const SizedBox(height: 3),
                                      Text(provider.category!.categoryName,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: _orange,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ],
                                ),
                              ),
                            ]),
                          ),

                          _Divider(),

                          // Detail rows
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(children: [
                              _DetailRow(
                                icon: Icons.calendar_today_outlined,
                                iconBg: const Color(0xFFF0F9FF),
                                iconColor: const Color(0xFF0EA5E9),
                                label: 'Date & Time',
                                value: DateFormat('EEEE, MMMM d yyyy')
                                    .format(scheduledAt),
                                subValue:
                                    DateFormat('h:mm a').format(scheduledAt),
                              ),
                              const SizedBox(height: 14),

                              // ── Phone ───────────────────────────────
                              _DetailRow(
                                icon: Icons.phone_outlined,
                                iconBg: const Color(0xFFF0FFF4),
                                iconColor: const Color(0xFF22C55E),
                                label: 'Phone Number',
                                value: phoneNumber,   // ← reads from field
                              ),
                              const SizedBox(height: 14),

                              _DetailRow(
                                icon: Icons.location_on_outlined,
                                iconBg: const Color(0xFFFFF7ED),
                                iconColor: _orange,
                                label: 'Service Address',
                                value: address,
                              ),
                              if (note != null && note!.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                _DetailRow(
                                  icon: Icons.notes_rounded,
                                  iconBg: const Color(0xFFF8FAFC),
                                  iconColor: const Color(0xFF64748B),
                                  label: 'Note',
                                  value: note!,
                                ),
                              ],
                              const SizedBox(height: 14),
                              _DetailRow(
                                icon: kSeverityOptions
                                    .firstWhere((o) => o.value == severity)
                                    .icon,
                                iconBg: _severityColor.withOpacity(0.1),
                                iconColor: _severityColor,
                                label: 'Urgency Level',
                                value: severity[0].toUpperCase() +
                                    severity.substring(1),
                                valueColor: _severityColor,
                              ),
                            ]),
                          ),

                          _Divider(),

                          // Price breakdown
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Price Breakdown',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _textPrimary)),
                                const SizedBox(height: 14),
                                _PriceRow(
                                  label: 'Base rate',
                                  value:
                                      'NPR ${provider.pricePerHour.toStringAsFixed(0)}/hr',
                                ),
                                const SizedBox(height: 8),
                                _PriceRow(
                                  label:
                                      'Urgency multiplier (×$_multiplier)',
                                  value: severity == 'normal'
                                      ? 'No extra charge'
                                      : '+${((_multiplier - 1) * 100).toStringAsFixed(0)}%',
                                  valueColor: severity == 'normal'
                                      ? _green
                                      : _severityColor,
                                ),
                                const SizedBox(height: 12),
                                Container(height: 1, color: _divider),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Effective rate',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: _textPrimary)),
                                    Text(
                                      'NPR ${_effectivePrice.toStringAsFixed(0)}/hr',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: _orange,
                                          letterSpacing: -0.5),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'By confirming, you agree that the final charge will be based on the actual hours of service at the effective rate shown above.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom buttons ──────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: state.status == BookingStatus.loading
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textPrimary,
                          side: const BorderSide(
                              color: Color(0xFFE2E8F0), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Edit',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: state.status == BookingStatus.loading
                            ? null
                            : () {
                                ref
                                    .read(bookingViewModelProvider.notifier)
                                    .createBooking(
                                      providerId:  provider.id,
                                      scheduledAt: scheduledAt,
                                      address:     address,
                                      phoneNumber: phoneNumber, // ← passed
                                      note:        note,
                                      severity:    severity,
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:         _orange,
                          foregroundColor:         Colors.white,
                          disabledBackgroundColor: _orange.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: state.status == BookingStatus.loading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_rounded, size: 20),
                                  SizedBox(width: 6),
                                  Text('Confirm Booking',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final Widget child;
  const _SummaryCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 3))
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: child,
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: const Color(0xFFF1F5F9));
}

class _InitialsWidget extends StatelessWidget {
  final String initials;
  const _InitialsWidget({required this.initials});
  @override
  Widget build(BuildContext context) => Center(
        child: Text(initials,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFF6B35))),
      );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color    iconBg;
  final Color    iconColor;
  final String   label;
  final String   value;
  final String?  subValue;
  final Color?   valueColor;

  const _DetailRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subValue,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600, letterSpacing: 0.6)),
                const SizedBox(height: 3),
                Text(value,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: valueColor ?? const Color(0xFF0F172A))),
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

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _PriceRow(
      {required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF64748B))),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF0F172A))),
        ],
      );
}