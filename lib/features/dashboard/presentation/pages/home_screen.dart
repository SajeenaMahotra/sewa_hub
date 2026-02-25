import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/widgets/primary_button.dart';
import 'package:sewa_hub/core/widgets/provider_card.dart';
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:sewa_hub/features/provider/presentation/pages/provider_detail_screen.dart';
import 'package:sewa_hub/features/provider/presentation/pages/providers_screen.dart';
import 'package:sewa_hub/features/provider/presentation/view_model/provider_view_model.dart';
import 'package:sewa_hub/features/provider/presentation/state/provider_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<Map<String, String>> categories = [
    {'title': 'Cleaning', 'imagePath': 'assets/icons/cleaning.png'},
    {'title': 'Plumbing', 'imagePath': 'assets/icons/plumbing.png'},
    {'title': 'Electrician', 'imagePath': 'assets/icons/electrician.png'},
    {'title': 'Carpenter', 'imagePath': 'assets/icons/carpenter.png'},
    {'title': 'AC Repair', 'imagePath': 'assets/icons/acrepair.png'},
    {'title': 'Painter', 'imagePath': 'assets/icons/paintroller.png'},
    {'title': 'Gardening', 'imagePath': 'assets/icons/gardening.png'},
    {'title': 'Laundry', 'imagePath': 'assets/icons/laundry.png'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providerViewModelProvider.notifier).loadProviders(reset: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(providerViewModelProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData _greetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_outlined;
    if (hour < 17) return Icons.wb_twilight_outlined;
    return Icons.nightlight_outlined;
  }

  Color _greetingIconColor() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Colors.amber;
    if (hour < 17) return Colors.orange;
    return Colors.indigo.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final providerState = ref.watch(providerViewModelProvider);
    final sessionService = ref.read(userSessionServiceProvider);
    final fullName = sessionService.userFullName ?? 'there';
    final firstName = fullName.trim().split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 72),
                _buildHeroSection(firstName),
                _buildCategoriesSection(),

                const SizedBox(height: 28),

                // ── Top Providers ────────────────────────────
                _buildTopProvidersPreview(providerState),

                const SizedBox(height: 28),

                // ── All Providers ────────────────────────────
                _buildAllProvidersGrid(providerState),

                const SizedBox(height: 30),
              ],
            ),
          ),
          _buildTopBar(firstName),
        ],
      ),
    );
  }

  // ── Fixed Top Bar (unchanged) ─────────────────────────────────────────────

  Widget _buildTopBar(String firstName) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20,
          right: 16,
          bottom: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.home_repair_service,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _greetingIcon(),
                        size: 13,
                        color: _greetingIconColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _greeting(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    firstName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Material(
                  color: Colors.grey.shade100,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Colors.black87,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero Section (unchanged) ──────────────────────────────────────────────

  Widget _buildHeroSection(String firstName) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF7940), Color(0xFFD9541E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What service do\nyou need today?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Trusted professionals, just a tap away.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for a service...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: PrimaryButton(
                          label: 'Search',
                          onTap: () {},
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          borderRadius: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Browse Categories (unchanged) ─────────────────────────────────────────

  Widget _buildCategoriesSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Browse Categories',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'What do you need help with?',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: const [
                      Text(
                        'See all',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward, size: 13, color: Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 105,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return _CategoryChip(
                  title: cat['title']!,
                  imagePath: cat['imagePath']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Providers — REDESIGNED ────────────────────────────────────────────

  Widget _buildTopProvidersPreview(ProviderState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Top Providers',
          subtitle: 'Verified professionals near you',
          onSeeAll: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProvidersScreen()),
          ),
        ),
        const SizedBox(height: 14),
        if (state.status == ProviderStatus.loading)
          const SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          )
        else if (state.providers.isEmpty)
          const SizedBox(
            height: 80,
            child: Center(child: Text('No providers available')),
          )
        else
          SizedBox(
            // Card is ~220px tall; 220 + padding fits cleanly
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: state.providers.length > 6
                  ? 6
                  : state.providers.length,
              itemBuilder: (context, index) {
                final provider = state.providers[index];
                return SizedBox(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ProviderCard(
                      provider: provider,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProviderDetailScreen(providerId: provider.id),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ── All Providers Grid — REDESIGNED ──────────────────────────────────────

  Widget _buildAllProvidersGrid(ProviderState state) {
    final providers = state.providers;
    final isLoadingMore = state.status == ProviderStatus.loadingMore;
    final isLoading = state.status == ProviderStatus.loading;

    if (isLoading || providers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'All Providers',
          subtitle: '${state.total} professionals available',
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            // Aspect ratio tuned to the compact card height
            childAspectRatio: 0.78,
          ),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index];
            return ProviderCard(
              provider: provider,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProviderDetailScreen(providerId: provider.id),
                ),
              ),
            );
          },
        ),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          ),
        if (!isLoadingMore && !state.hasMore && providers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'All ${state.total} providers loaded',
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Shared Section Header ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Category Chip (unchanged) ─────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String title;
  final String imagePath;

  const _CategoryChip({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.miscellaneous_services,
                size: 32,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
