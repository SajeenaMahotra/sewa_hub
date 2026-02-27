import 'package:flutter/material.dart';
import 'package:sewa_hub/core/widgets/primary_button.dart';
import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';

class ProviderCard extends StatefulWidget {
  final ProviderEntity provider;
  final VoidCallback? onTap;
  final VoidCallback? onBookNow;

  const ProviderCard({
    super.key,
    required this.provider,
    this.onTap,
    this.onBookNow,
  });

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
          width: double.infinity,
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
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar row ──────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Avatar(imageUrl: _imageUrl, initials: _initials),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p.user?.fullname ?? 'Unknown',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
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

                const SizedBox(height: 14),

                // ── Experience ───────────────────────────────
                _StatTile(
                  icon: Icons.work_history_outlined,
                  iconColor: const Color(0xFFFF6B35),
                  iconBg: const Color(0xFFFFF3EE),
                  value: '${p.experienceYears} yrs',
                  label: 'Experience',
                  valueColor: const Color(0xFF0F172A),
                ),

                const SizedBox(height: 8),

                // ── Rating row ───────────────────────────────
                _StatTile(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFC107),
                  iconBg: const Color(0xFFFFFBEB),
                  value: hasRating
                      ? p.rating.toStringAsFixed(1)
                      : 'No ratings yet',
                  label: 'Rating',
                  valueColor: hasRating
                      ? const Color(0xFF92400E)
                      : const Color(0xFF94A3B8),
                ),

                const SizedBox(height: 16),

                // ── Price + Book Now row ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price — always fully visible
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Rs. ${p.pricePerHour.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFFF6B35),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const TextSpan(
                            text: ' /hr',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Compact fixed-width button
                    SizedBox(
                      width: 84,
                      child: PrimaryButton(
                        label: 'Book now',
                        onTap: widget.onBookNow ?? widget.onTap,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//  Stat Tile 
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;
  final Color valueColor;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 13),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//  Avatar 

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final String initials;
  const _Avatar({required this.imageUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
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
              fontSize: 17,
              fontWeight: FontWeight.w800)),
    );
  }
}

//  Category Pill 

class _CategoryPill extends StatelessWidget {
  final String label;
  const _CategoryPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFFE85A1A),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

//  Rating Badge

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 11),
          const SizedBox(width: 2),
          Text(rating.toStringAsFixed(1),
              style: const TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}