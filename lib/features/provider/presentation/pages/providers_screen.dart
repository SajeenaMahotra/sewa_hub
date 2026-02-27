import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/widgets/dotted_background.dart';
import 'package:sewa_hub/core/widgets/provider_card.dart';
import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';
import 'package:sewa_hub/features/provider/presentation/pages/provider_detail_screen.dart';
import 'package:sewa_hub/features/provider/presentation/state/provider_state.dart';
import 'package:sewa_hub/features/provider/presentation/view_model/provider_view_model.dart';

enum _SortOption { none, priceLow, priceHigh, ratingHigh, expHigh }

class ProvidersScreen extends ConsumerStatefulWidget {
  final String? initialSearch; // ← new
  final String? initialCategory; // ← new

  const ProvidersScreen({super.key, this.initialSearch, this.initialCategory});

  @override
  ConsumerState<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends ConsumerState<ProvidersScreen> {
  static const _orange = Color(0xFFFF6B35);
  static const _textPrimary = Color(0xFF0F172A);
  static const _divider = Color(0xFFF1F5F9);

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'all';
  _SortOption _sortOption = _SortOption.none;

  // Price range
  double _minPrice = 0;
  double _maxPrice = 10000;
  RangeValues _priceRange = const RangeValues(0, 10000);

  // Experience filter
  int _minExperience = 0; // 0 = any

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null && widget.initialSearch!.isNotEmpty) {
      _searchController.text = widget.initialSearch!;
      _searchQuery = widget.initialSearch!.toLowerCase();
    }
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(providerViewModelProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getCategories(List<ProviderEntity> providers) {
    final cats =
        providers
            .map((p) => p.category?.categoryName ?? '')
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['all', ...cats];
  }

  List<ProviderEntity> _applyFiltersAndSort(List<ProviderEntity> providers) {
    var result = providers.where((p) {
      // Search
      final name = p.user?.fullname.toLowerCase() ?? '';
      final cat = p.category?.categoryName.toLowerCase() ?? '';
      final bio = p.bio?.toLowerCase() ?? '';
      final matchesSearch =
          _searchQuery.isEmpty ||
          name.contains(_searchQuery) ||
          cat.contains(_searchQuery) ||
          bio.contains(_searchQuery);

      // Category
      final matchesCat =
          _selectedCategory == 'all' ||
          (p.category?.categoryName == _selectedCategory);

      // Price range
      final matchesPrice =
          p.pricePerHour >= _priceRange.start &&
          p.pricePerHour <= _priceRange.end;

      // Experience
      final matchesExp =
          _minExperience == 0 || p.experienceYears >= _minExperience;

      return matchesSearch && matchesCat && matchesPrice && matchesExp;
    }).toList();

    // Sort
    switch (_sortOption) {
      case _SortOption.priceLow:
        result.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case _SortOption.priceHigh:
        result.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
        break;
      case _SortOption.ratingHigh:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _SortOption.expHigh:
        result.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
      case _SortOption.none:
        break;
    }

    return result;
  }

  bool get _hasActiveFilters =>
      _selectedCategory != 'all' ||
      _sortOption != _SortOption.none ||
      _minExperience != 0 ||
      _priceRange.start != _minPrice ||
      _priceRange.end != _maxPrice;

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'all';
      _sortOption = _SortOption.none;
      _minExperience = 0;
      _priceRange = RangeValues(_minPrice, _maxPrice);
    });
  }

  void _showFilterSheet(BuildContext context, List<ProviderEntity> providers) {
    // Compute price bounds from data
    if (providers.isNotEmpty) {
      final prices = providers.map((p) => p.pricePerHour).toList();
      _minPrice = prices.reduce((a, b) => a < b ? a : b);
      _maxPrice = prices.reduce((a, b) => a > b ? a : b);
      if (_priceRange.start < _minPrice || _priceRange.end > _maxPrice) {
        _priceRange = RangeValues(_minPrice, _maxPrice);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        categories: _getCategories(providers),
        selectedCategory: _selectedCategory,
        sortOption: _sortOption,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        priceRange: _priceRange,
        minExperience: _minExperience,
        onApply: (cat, sort, range, exp) {
          setState(() {
            _selectedCategory = cat;
            _sortOption = sort;
            _priceRange = range;
            _minExperience = exp;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerViewModelProvider);
    final filtered = _applyFiltersAndSort(state.providers);
    final categories = _getCategories(state.providers);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: DottedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  children: [
                    // Title row
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: _textPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Service Providers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        // Filter button with active indicator
                        GestureDetector(
                          onTap: () =>
                              _showFilterSheet(context, state.providers),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _hasActiveFilters
                                  ? const Color(0xFFFFF3EE)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _hasActiveFilters
                                    ? _orange
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  size: 15,
                                  color: _hasActiveFilters
                                      ? _orange
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Filter',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _hasActiveFilters
                                        ? _orange
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                if (_hasActiveFilters) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: _orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Search bar
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.toLowerCase()),
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name, category...',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: Color(0xFF94A3B8),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Category chips
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final cat = categories[i];
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _orange.withOpacity(0.12)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? _orange
                                      : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                cat == 'all' ? 'All' : cat,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? _orange
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Container(height: 1, color: _divider),

              // Results count + active sort label
              if (state.providers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        '${filtered.length} provider${filtered.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      if (_sortOption != _SortOption.none) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3EE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _sortLabel(_sortOption),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _orange,
                            ),
                          ),
                        ),
                      ],
                      if (_hasActiveFilters) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: _clearFilters,
                          child: const Text(
                            'Clear all',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _orange,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // ── Body ────────────────────────────────────────────────
              Expanded(child: _buildBody(state, filtered)),
            ],
          ),
        ),
      ),
    );
  }

  String _sortLabel(_SortOption o) {
    switch (o) {
      case _SortOption.priceLow:
        return 'Price: Low → High';
      case _SortOption.priceHigh:
        return 'Price: High → Low';
      case _SortOption.ratingHigh:
        return 'Top Rated';
      case _SortOption.expHigh:
        return 'Most Experienced';
      case _SortOption.none:
        return '';
    }
  }

  Widget _buildBody(ProviderState state, List<ProviderEntity> filtered) {
    if (state.status == ProviderStatus.loading && state.providers.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _orange));
    }

    if (state.status == ProviderStatus.error && state.providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'Something went wrong',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref
                  .read(providerViewModelProvider.notifier)
                  .loadProviders(reset: true),
              child: const Text('Try again', style: TextStyle(color: _orange)),
            ),
          ],
        ),
      );
    }

    if (state.providers.isEmpty) {
      return const Center(
        child: Text(
          'No providers found',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    if (filtered.isEmpty) {
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
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: _orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No providers found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _clearFilters();
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Text(
                'Clear all filters',
                style: TextStyle(color: _orange, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _orange,
      onRefresh: () => ref
          .read(providerViewModelProvider.notifier)
          .loadProviders(reset: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount:
            filtered.length +
            (state.status == ProviderStatus.loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= filtered.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: _orange),
              ),
            );
          }
          final provider = filtered[index];
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
    );
  }
}

// ── Filter Bottom Sheet ───────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final List<String> categories;
  final String selectedCategory;
  final _SortOption sortOption;
  final double minPrice;
  final double maxPrice;
  final RangeValues priceRange;
  final int minExperience;
  final void Function(String cat, _SortOption sort, RangeValues range, int exp)
  onApply;

  const _FilterSheet({
    required this.categories,
    required this.selectedCategory,
    required this.sortOption,
    required this.minPrice,
    required this.maxPrice,
    required this.priceRange,
    required this.minExperience,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  static const _orange = Color(0xFFFF6B35);

  late String _category;
  late _SortOption _sort;
  late RangeValues _priceRange;
  late int _minExp;

  static const _expOptions = [0, 1, 2, 3, 5, 10];

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _sort = widget.sortOption;
    _priceRange = widget.priceRange;
    _minExp = widget.minExperience;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Sort',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _category = 'all';
                    _sort = _SortOption.none;
                    _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
                    _minExp = 0;
                  }),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: _orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // ── Sort ──────────────────────────────────────────────────
            _SheetSection(
              label: 'Sort By',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SortChip(
                    label: 'Default',
                    value: _SortOption.none,
                    selected: _sort,
                    onTap: (v) => setState(() => _sort = v),
                  ),
                  _SortChip(
                    label: 'Price: Low → High',
                    value: _SortOption.priceLow,
                    selected: _sort,
                    onTap: (v) => setState(() => _sort = v),
                  ),
                  _SortChip(
                    label: 'Price: High → Low',
                    value: _SortOption.priceHigh,
                    selected: _sort,
                    onTap: (v) => setState(() => _sort = v),
                  ),
                  _SortChip(
                    label: 'Top Rated',
                    value: _SortOption.ratingHigh,
                    selected: _sort,
                    onTap: (v) => setState(() => _sort = v),
                  ),
                  _SortChip(
                    label: 'Most Experienced',
                    value: _SortOption.expHigh,
                    selected: _sort,
                    onTap: (v) => setState(() => _sort = v),
                  ),
                ],
              ),
            ),

            // ── Price Range ───────────────────────────────────────────
            _SheetSection(
              label: 'Price Per Hour (NPR)',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PriceLabel(
                        'NPR ${_priceRange.start.toStringAsFixed(0)}',
                      ),
                      _PriceLabel('NPR ${_priceRange.end.toStringAsFixed(0)}'),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: widget.minPrice,
                    max: widget.maxPrice,
                    divisions: 20,
                    activeColor: _orange,
                    inactiveColor: const Color(0xFFFFDDCC),
                    onChanged: (v) => setState(() => _priceRange = v),
                  ),
                ],
              ),
            ),

            // ── Min Experience ────────────────────────────────────────
            _SheetSection(
              label: 'Minimum Experience',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _expOptions.map((e) {
                  final isSelected = _minExp == e;
                  return GestureDetector(
                    onTap: () => setState(() => _minExp = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _orange.withOpacity(0.12)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? _orange : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        e == 0 ? 'Any' : '$e+ yrs',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? _orange : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // Apply button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_category, _sort, _priceRange, _minExp);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _SheetSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final _SortOption value;
  final _SortOption selected;
  final void Function(_SortOption) onTap;

  const _SortChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  static const _orange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? _orange.withOpacity(0.12)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _orange : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? _orange : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  final String text;
  const _PriceLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3EE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFDDCC)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFF6B35),
        ),
      ),
    );
  }
}
