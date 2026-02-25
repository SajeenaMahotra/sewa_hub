import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Provider Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: () {
        if (state.status == ProviderStatus.detailLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.orange));
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Provider info card ──────────────────────────────────
          _sectionCard(
            child: Column(
              children: [
                // Top orange bar
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _initialsAvatar(provider.user?.fullname),
                              ),
                            )
                          : _initialsAvatar(provider.user?.fullname),
                      const SizedBox(width: 16),
                      // Name + meta
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.user?.fullname ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                _metaChip(
                                  Icons.star_border,
                                  provider.rating > 0
                                      ? provider.rating.toStringAsFixed(1)
                                      : '— No ratings yet',
                                ),
                                _metaChip(
                                  Icons.access_time_outlined,
                                  '${provider.experienceYears} yrs experience',
                                ),
                                if (provider.address != null)
                                  _metaChip(
                                    Icons.location_on_outlined,
                                    provider.address!,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── About ───────────────────────────────────────────────
          if (provider.bio != null && provider.bio!.isNotEmpty)
            _sectionCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      provider.bio!,
                      style: TextStyle(
                          color: Colors.grey[700], height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          // ── Contact Info ────────────────────────────────────────
          _sectionCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Info',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (provider.user?.email != null)
                    _contactRow(
                      icon: Icons.email_outlined,
                      iconBg: Colors.red.shade50,
                      iconColor: Colors.red,
                      label: 'EMAIL',
                      value: provider.user!.email,
                    ),
                  if (provider.phone != null) ...[
                    const SizedBox(height: 12),
                    _contactRow(
                      icon: Icons.phone_outlined,
                      iconBg: Colors.green.shade50,
                      iconColor: Colors.green,
                      label: 'PHONE',
                      value: provider.phone!,
                    ),
                  ],
                  if (provider.address != null) ...[
                    const SizedBox(height: 12),
                    _contactRow(
                      icon: Icons.location_on_outlined,
                      iconBg: Colors.orange.shade50,
                      iconColor: Colors.orange,
                      label: 'ADDRESS',
                      value: provider.address!,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Reviews ─────────────────────────────────────────────
          _sectionCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        provider.reviewCount == 0
                            ? 'No reviews yet'
                            : '${provider.reviewCount} reviews',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                  if (provider.reviewCount == 0) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.star_border,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          const Text(
                            'Reviews coming soon',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Be the first to book and review this provider',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Booking Panel ────────────────────────────────────────
          _BookingPanel(provider: provider),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _contactRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _initialsAvatar(String? name) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }
}

// ── Booking Panel Widget ─────────────────────────────────────────────────────

class _BookingPanel extends StatefulWidget {
  final ProviderEntity provider;

  const _BookingPanel({required this.provider});

  @override
  State<_BookingPanel> createState() => _BookingPanelState();
}

class _BookingPanelState extends State<_BookingPanel> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.orange),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.orange),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orange header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BOOK THIS PROVIDER',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'NPR ${widget.provider.pricePerHour.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '/hr',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DATE
                _fieldLabel('DATE'),
                const SizedBox(height: 6),
                _inputField(
                  child: InkWell(
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDate == null
                              ? 'mm/dd/yyyy'
                              : '${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                          style: TextStyle(
                            color: _selectedDate == null
                                ? Colors.grey
                                : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.calendar_month_outlined,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // TIME
                _fieldLabel('TIME'),
                const SizedBox(height: 6),
                _inputField(
                  child: InkWell(
                    onTap: _pickTime,
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_outlined,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _selectedTime == null
                              ? '--:-- --'
                              : _selectedTime!.format(context),
                          style: TextStyle(
                            color: _selectedTime == null
                                ? Colors.grey
                                : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.access_time,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // YOUR ADDRESS
                _fieldLabel('YOUR ADDRESS'),
                const SizedBox(height: 6),
                _inputField(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            hintText:
                                'e.g. 45 Thamel Marg, Kathmandu 44600',
                            hintStyle: TextStyle(
                                color: Colors.grey, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Use my current location
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        // TODO: implement location
                      },
                      child: const Text(
                        'Use my current location',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // NOTE
                Row(
                  children: [
                    _fieldLabel('NOTE'),
                    const SizedBox(width: 6),
                    Text('(optional)',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Describe what you need...',
                      hintStyle:
                          TextStyle(color: Colors.grey, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Rate summary
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rate',
                          style: TextStyle(color: Colors.black54)),
                      Text(
                        'NPR ${widget.provider.pricePerHour.toStringAsFixed(0)}/hr',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Request Booking button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: implement booking
                    },
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.white),
                    label: const Text(
                      'Request Booking',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Provider will accept or reject your request',
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _inputField({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}