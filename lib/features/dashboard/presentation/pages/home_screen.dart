import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/widgets/dotted_background.dart';
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
   
    // ── Global responsive helpers ──────────────────────────────────────────
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    // Scale factor: 375 baseline (small phone). Clamp so tablets don't go wild.
    final sf = (screenWidth / 375).clamp(0.9, 1.5);
    // Top-bar height grows with status bar
    final topBarHeight = mq.padding.top + 64.0 * sf;

    return Scaffold(
      body: DottedBackground(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topBarHeight),
                  _buildHeroSection(sf),
                  _buildCategoriesSection(sf),
                  SizedBox(height: 24 * sf),
                  _buildTopProvidersPreview(providerState, sf, screenWidth),
                  SizedBox(height: 24 * sf),
                  _buildAllProvidersGrid(providerState, sf, screenWidth),
                  SizedBox(height: 30 * sf),
                ],
              ),
            ),
            _buildTopBar(fullName, sf, topBarHeight),
          ],
        ),
      ),
    );
  }

  //  Fixed Top Bar 
  Widget _buildTopBar(String fullName, double sf, double topBarHeight) {
    final mq = MediaQuery.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: topBarHeight,
        padding: EdgeInsets.only(
          top: mq.padding.top + 10 * sf,
          left: 20 * sf,
          right: 16 * sf,
          bottom: 10 * sf,
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
            // Greeting + full name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _greetingIcon(),
                        size: 12 * sf,
                        color: _greetingIconColor(),
                      ),
                      SizedBox(width: 4 * sf),
                      Text(
                        _greeting(),
                        style: TextStyle(
                          fontSize: 11 * sf,
                          color: Colors.grey[700],   
                          fontWeight: FontWeight.w500, 
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1 * sf),
                  Text(
                    fullName, 
                    style: TextStyle(
                      fontSize: 16 * sf,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Notification bell — no red dot, no Stack
            Material(
              color: Colors.grey.shade100,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.all(9 * sf),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.black87,
                    size: 20 * sf,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Hero Section 

  Widget _buildHeroSection(double sf) {
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
          // Decorative circles — scale with sf
          Positioned(
            top: -50 * sf,
            right: -50 * sf,
            child: Container(
              width: 200 * sf,
              height: 200 * sf,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30 * sf,
            right: 40 * sf,
            child: Container(
              width: 120 * sf,
              height: 120 * sf,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                20 * sf, 24 * sf, 20 * sf, 28 * sf),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What service do\nyou need today?',
                  style: TextStyle(
                    fontSize: 24 * sf,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6 * sf),
                Text(
                  'Trusted professionals, just a tap away.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.5 * sf,
                  ),
                ),
                SizedBox(height: 20 * sf),
                // Search bar
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
                      SizedBox(width: 14 * sf),
                      Icon(Icons.search,
                          color: Colors.grey.shade400, size: 18 * sf),
                      SizedBox(width: 8 * sf),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(fontSize: 13 * sf),
                          decoration: InputDecoration(
                            hintText: 'Search for a service...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13 * sf,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12 * sf,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5 * sf),
                        child: PrimaryButton(
                          label: 'Search',
                          onTap: () {},
                          padding: EdgeInsets.symmetric(
                            horizontal: 18 * sf,
                            vertical: 11 * sf,
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

  //  Browse Categories

  Widget _buildCategoriesSection(double sf) {
    // Category chip height scales with sf
    final chipListHeight = 96.0 * sf;

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
            padding: EdgeInsets.symmetric(
                horizontal: 20 * sf, vertical: 18 * sf),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse Categories',
                      style: TextStyle(
                        fontSize: 16 * sf,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 3 * sf),
                    Text(
                      'What do you need help with?',
                      style: TextStyle(
                          fontSize: 11.5 * sf, color: Colors.grey),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'See all',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12.5 * sf,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 2 * sf),
                      Icon(Icons.arrow_forward,
                          size: 12 * sf, color: Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: chipListHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                  left: 14 * sf, right: 14 * sf, bottom: 16 * sf),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return _CategoryChip(
                  title: cat['title']!,
                  imagePath: cat['imagePath']!,
                  sf: sf,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //  Top Providers 

  Widget _buildTopProvidersPreview(
      ProviderState state, double sf, double screenWidth) {
    // Card width = ~52% of screen; height derived from aspect ratio
    final cardWidth = screenWidth * 0.52;
    final cardHeight = cardWidth * 1.05;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Top Providers',
          subtitle: 'Verified professionals near you',
          sf: sf,
          onSeeAll: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProvidersScreen()),
          ),
        ),
        SizedBox(height: 12 * sf),
        if (state.status == ProviderStatus.loading)
          SizedBox(
            height: cardHeight,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          )
        else if (state.providers.isEmpty)
          SizedBox(
            height: 80 * sf,
            child: const Center(child: Text('No providers available')),
          )
        else
          SizedBox(
            height: cardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16 * sf, right: 8 * sf),
              physics: const BouncingScrollPhysics(),
              itemCount:
                  state.providers.length > 6 ? 6 : state.providers.length,
              itemBuilder: (context, index) {
                final provider = state.providers[index];
                return SizedBox(
                  width: cardWidth,
                  child: Padding(
                    padding: EdgeInsets.only(right: 12 * sf),
                    child: ProviderCard(
                      provider: provider,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProviderDetailScreen(
                              providerId: provider.id),
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

  //  All Providers Grid 

  Widget _buildAllProvidersGrid(
      ProviderState state, double sf, double screenWidth) {
    final providers = state.providers;
    final isLoadingMore = state.status == ProviderStatus.loadingMore;
    final isLoading = state.status == ProviderStatus.loading;

    if (isLoading || providers.isEmpty) return const SizedBox.shrink();

    // Responsive column count: 2 for phones, 3 for tablets (≥600px)
    final crossAxisCount = screenWidth >= 600 ? 3 : 2;
    // Aspect ratio: wider screens can afford a slightly taller card
    final aspectRatio = screenWidth >= 600 ? 0.80 : 0.72;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'All Providers',
          subtitle: '${state.total} professionals available',
          sf: sf,
        ),
        SizedBox(height: 12 * sf),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16 * sf),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12 * sf,
            mainAxisSpacing: 12 * sf,
            childAspectRatio: aspectRatio,
          ),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index];
            return ProviderCard(
              provider: provider,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProviderDetailScreen(providerId: provider.id),
                ),
              ),
            );
          },
        ),
        if (isLoadingMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20 * sf),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          ),
        if (!isLoadingMore && !state.hasMore && providers.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: 20 * sf, horizontal: 40 * sf),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * sf),
                  child: Text(
                    'All ${state.total} providers loaded',
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 11 * sf),
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

//  Shared Section Header 

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onSeeAll;
  final double sf;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.sf,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sf),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16 * sf,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2 * sf),
                Text(
                  subtitle,
                  style:
                      TextStyle(fontSize: 11.5 * sf, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 11 * sf,
                  vertical: 6 * sf,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11.5 * sf,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 3 * sf),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 9 * sf,
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

//  Category Chip 

class _CategoryChip extends StatelessWidget {
  final String title;
  final String imagePath;
  final double sf;

  const _CategoryChip({
    required this.title,
    required this.imagePath,
    required this.sf,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(right: 10 * sf),
        padding: EdgeInsets.symmetric(
            horizontal: 12 * sf, vertical: 8 * sf),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * sf),
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
              width: 30 * sf,
              height: 30 * sf,
              errorBuilder: (_, __, ___) => Icon(
                Icons.miscellaneous_services,
                size: 30 * sf,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 4 * sf),
            Text(
              title,
              style: TextStyle(
                fontSize: 9.5 * sf,
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