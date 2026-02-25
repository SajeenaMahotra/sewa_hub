// lib/core/widgets/provider_card.dart

import 'package:flutter/material.dart';
import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';

class ProviderCard extends StatefulWidget {
  final ProviderEntity provider;
  final VoidCallback? onTap;

  const ProviderCard({super.key, required this.provider, this.onTap});

  @override
  State<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<ProviderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.965)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'http://10.0.2.2:5050$path';
  }

  String get _imageUrl => _resolveImageUrl(
      widget.provider.imageUrl ?? widget.provider.user?.imageUrl);

  String get _initials {
    final name = widget.provider.user?.fullname ?? '';
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    return (parts.length >= 2
            ? '${parts[0][0]}${parts[1][0]}'
            : name[0])
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final hasRating = p.rating > 0;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Avatar(imageUrl: _imageUrl, initials: _initials),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.user?.fullname ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (p.category != null)
                                  _CategoryPill(p.category!.categoryName),
                              ],
                            ),
                          ),
                          if (hasRating) ...[
                            const SizedBox(width: 4),
                            _RatingBadge(rating: p.rating),
                          ],
                        ],
                      ),

                      const SizedBox(height: 12),
                      Container(height: 1, color: const Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // Stats
                      Row(
                        children: [
                          _StatItem(
                            icon: Icons.work_history_outlined,
                            value: '${p.experienceYears} yrs',
                            label: 'Exp',
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 8),
                            color: const Color(0xFFE2E8F0),
                          ),
                          _StatItem(
                            icon: Icons.payments_outlined,
                            value:
                                'NPR ${p.pricePerHour.toStringAsFixed(0)}',
                            label: '/hr',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Button
                      _BookNowButton(onTap: widget.onTap),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final String initials;
  const _Avatar({required this.imageUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFF8FAFC),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? Image.network(imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _InitialsWidget(initials))
          : _InitialsWidget(initials),
    );
  }
}

class _InitialsWidget extends StatelessWidget {
  final String text;
  const _InitialsWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 18,
              fontWeight: FontWeight.w800)),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  const _CategoryPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFFF6B35).withOpacity(0.25), width: 1),
      ),
      child: Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Color(0xFFE85A1A),
              fontSize: 10.5,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 12),
          const SizedBox(width: 2),
          Text(rating.toStringAsFixed(1),
              style: const TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatItem(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFFF6B35), size: 14),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookNowButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _BookNowButton({this.onTap});

  @override
  State<_BookNowButton> createState() => _BookNowButtonState();
}

class _BookNowButtonState extends State<_BookNowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: _pressed
                ? [const Color(0xFFCC3D0A), const Color(0xFFB33200)]
                : [const Color(0xFFFF6B35), const Color(0xFFE84A0E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Book Now',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)),
            SizedBox(width: 6),
            Icon(Icons.north_east_rounded, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}