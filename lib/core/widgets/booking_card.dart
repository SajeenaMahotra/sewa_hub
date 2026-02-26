import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sewa_hub/features/booking/domain/entities/booking_entity.dart';
import 'package:sewa_hub/features/booking/presentation/pages/booking_detail_page.dart';
import 'package:sewa_hub/features/booking/presentation/widgets/booking_status_badge.dart';

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCancel,
  });

  static const _orange = Color(0xFFFF6B35);
  static const _textPrimary = Color(0xFF0F172A);

  String get _providerName {
    if (booking.provider is Map) {
      final providerMap = booking.provider as Map;
      final user = providerMap['Useruser_id'];
      if (user is Map) return user['fullname']?.toString() ?? 'Provider';
    }
    return 'Provider';
  }

  String get _providerImage {
    if (booking.provider is Map) {
      final providerMap = booking.provider as Map;
      final user = providerMap['Useruser_id'];
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

  @override
  Widget build(BuildContext context) {
    final name = _providerName;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailPage(booking: booking),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top gradient bar
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF9A6C)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: avatar + name + status + chevron
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFFFF3EE),
                          border: Border.all(color: const Color(0xFFFFDDCC)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _providerImage.isNotEmpty
                            ? Image.network(
                                _providerImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    _initials(name),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: _orange),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  _initials(name),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _orange),
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      BookingStatusBadge(status: booking.status),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: Color(0xFFCBD5E1)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Date & address
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: DateFormat('EEE, MMM d yyyy • h:mm a')
                        .format(booking.scheduledAt),
                  ),
                  const SizedBox(height: 5),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: booking.address,
                  ),

                  const SizedBox(height: 12),

                  // Price + severity + cancel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _SeverityChip(severity: booking.severity),
                          const SizedBox(width: 8),
                          Text(
                            'NPR ${booking.effectivePricePerHour.toStringAsFixed(0)}/hr',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _orange,
                            ),
                          ),
                        ],
                      ),
                      if (booking.status == 'pending' && onCancel != null)
                        GestureDetector(
                          onTap: onCancel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFEF4444), width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEF4444),
                              ),
                            ),
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final String severity;
  const _SeverityChip({required this.severity});

  Color get _color {
    switch (severity) {
      case 'urgent':
        return const Color(0xFFF59E0B);
      case 'emergency':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF22C55E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        severity[0].toUpperCase() + severity.substring(1),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}