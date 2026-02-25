import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/widgets/button_outline.dart';
import 'package:sewa_hub/core/widgets/primary_button.dart';
import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';
import 'package:sewa_hub/features/provider/presentation/state/provider_state.dart';
import 'package:sewa_hub/features/provider/presentation/view_model/provider_view_model.dart';

class ProviderDetailScreen extends ConsumerStatefulWidget {
  final String providerId;

  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  ConsumerState<ProviderDetailScreen> createState() =>
      _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends ConsumerState<ProviderDetailScreen> {
  // ── Design tokens ──────────────────────────────────────────────────────────
  static const _orange = Color(0xFFFF6B35);
  static const _bg = Color(0xFFF7F7F5);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _dividerColor = Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(providerViewModelProvider.notifier)
          .getProviderById(widget.providerId);
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerViewModelProvider);

    return Scaffold(
      backgroundColor: _bg,
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
          'Provider Details',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _dividerColor),
        ),
      ),
      body: () {
        if (state.status == ProviderStatus.detailLoading) {
          return const Center(
              child: CircularProgressIndicator(color: _orange));
        }
        if (state.status == ProviderStatus.error) {
          return Center(
              child: Text(state.errorMessage ?? 'Something went wrong'));
        }
        if (state.selectedProvider != null) {
          return _buildDetail(state.selectedProvider!);
        }
        return const SizedBox.shrink();
      }(),
    );
  }

  Widget _buildDetail(ProviderEntity provider) {
  final imageUrl =
      _resolveImageUrl(provider.imageUrl ?? provider.user?.imageUrl);

  return Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          child: _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Gradient Bar ─────────────────────
                Container(
                  height: 5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF9A6C)],
                    ),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),

                // ── Hero Section ─────────────────────
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(imageUrl, provider.user?.fullname),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.user?.fullname ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (provider.category != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                provider.category!.categoryName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                _StatBadge(
                                  icon: Icons.star_rounded,
                                  iconColor: const Color(0xFFFFC107),
                                  label: provider.rating > 0
                                      ? provider.rating.toStringAsFixed(1)
                                      : 'No ratings',
                                ),
                                _StatBadge(
                                  icon: Icons.work_history_outlined,
                                  iconColor: _orange,
                                  label: '${provider.experienceYears} yrs exp',
                                ),
                                if (provider.address != null)
                                  _StatBadge(
                                    icon: Icons.location_on_outlined,
                                    iconColor: _textSecondary,
                                    label: provider.address!,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1, color: _dividerColor),

                // ── Price Section ─────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Hourly Rate',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textSecondary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Charged per hour of service',
                            style:
                                TextStyle(fontSize: 12, color: Color(0xFFADB5BD)),
                          ),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'NPR ${provider.pricePerHour.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: _orange,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const TextSpan(
                              text: ' /hr',
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── About Section ─────────────────────
                if (provider.bio != null && provider.bio!.isNotEmpty) ...[
                  const Padding(
                      padding: EdgeInsets.only(left: 20, top: 10),
                      child: _SectionLabel(label: 'About')),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      provider.bio!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: _textSecondary,
                        height: 1.65,
                      ),
                    ),
                  ),
                ],

                // ── Contact Info ─────────────────────
                const Padding(
                    padding: EdgeInsets.only(left: 20, top: 10),
                    child: _SectionLabel(label: 'Contact Info')),
                Column(
                  children: [
                    if (provider.user?.email != null)
                      _ContactTile(
                        icon: Icons.email_outlined,
                        iconBg: const Color(0xFFFFF0F0),
                        iconColor: const Color(0xFFEF4444),
                        label: 'Email',
                        value: provider.user!.email,
                        isFirst: true,
                        isLast: provider.phone == null && provider.address == null,
                      ),
                    if (provider.phone != null)
                      _ContactTile(
                        icon: Icons.phone_outlined,
                        iconBg: const Color(0xFFF0FFF4),
                        iconColor: const Color(0xFF22C55E),
                        label: 'Phone',
                        value: provider.phone!,
                        isFirst: provider.user?.email == null,
                        isLast: provider.address == null,
                      ),
                    if (provider.address != null)
                      _ContactTile(
                        icon: Icons.location_on_outlined,
                        iconBg: const Color(0xFFFFF7ED),
                        iconColor: _orange,
                        label: 'Address',
                        value: provider.address!,
                        isFirst:
                            provider.user?.email == null && provider.phone == null,
                        isLast: true,
                      ),
                  ],
                ),

                // ── Reviews ───────────────────────────
                const Padding(
                    padding: EdgeInsets.only(left: 20, top: 10),
                    child: _SectionLabel(label: 'Reviews')),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Customer Reviews',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: provider.reviewCount > 0
                                  ? const Color(0xFFFFF7ED)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              provider.reviewCount == 0
                                  ? 'No reviews'
                                  : '${provider.reviewCount} reviews',
                              style: TextStyle(
                                color: provider.reviewCount > 0
                                    ? _orange
                                    : _textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (provider.reviewCount == 0) ...[
                        const SizedBox(height: 28),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0), width: 2),
                                ),
                                child: const Icon(Icons.star_outline_rounded,
                                    size: 32, color: Color(0xFFCBD5E1)),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'No reviews yet',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Be the first to book and share your experience',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 13, color: _textSecondary),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ── Bottom Bar ───────────────────────────────
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Row(
          children: [
            Expanded(
              child: ButtonOutline(
                text: 'Message',
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 50,
                child: PrimaryButton(
                  label: 'Book now',
                  onTap: () {},
                  borderRadius: 15,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildAvatar(String imageUrl, String? name) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFFFF3EE),
        border: Border.all(color: const Color(0xFFFFDDCC), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? Image.network(imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initialsWidget(name))
          : _initialsWidget(name),
    );
  }

  Widget _initialsWidget(String? name) {
    return Center(
      child: Text(
        _initials(name),
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: _orange,
        ),
      ),
    );
  }
}

// ── Shared Sub-widgets ────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  const _ContactTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            isFirst ? 18 : 14,
            20,
            isLast ? 18 : 14,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
            indent: 78,
            endIndent: 0,
          ),
      ],
    );
  }
} 