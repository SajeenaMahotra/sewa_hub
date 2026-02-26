import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/core/widgets/dotted_background.dart';
import 'package:sewa_hub/features/booking/presentation/pages/booking_summary_page.dart';
import 'package:sewa_hub/features/booking/presentation/state/booking_state.dart';
import 'package:sewa_hub/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:sewa_hub/features/booking/presentation/widgets/severity_selector.dart';
import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';

class CreateBookingPage extends ConsumerStatefulWidget {
  final ProviderEntity provider;

  const CreateBookingPage({super.key, required this.provider});

  @override
  ConsumerState<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends ConsumerState<CreateBookingPage> {
  static const _orange = Color(0xFFFF6B35);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _divider = Color(0xFFF1F5F9);

  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _severity = 'normal';

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
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

  double get _effectivePrice {
    final multiplier = kSeverityOptions
        .firstWhere((o) => o.value == _severity)
        .multiplier;
    return widget.provider.pricePerHour * multiplier;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _orange),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _orange),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  DateTime? get _scheduledAt {
    if (_selectedDate == null || _selectedTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  void _submit() {
    if (_scheduledAt == null) {
      SnackbarUtils.showError(context,
          message: 'Please select date and time');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      SnackbarUtils.showError(context, message: 'Please enter your address');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSummaryPage(
          provider: widget.provider,
          scheduledAt: _scheduledAt!,
          address: _addressController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          severity: _severity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingViewModelProvider);

    final provider = widget.provider;
    final imageUrl =
        _resolveImageUrl(provider.imageUrl ?? provider.user?.imageUrl);
    final name = provider.user?.fullname ?? 'Provider';

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
          'Book Service',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
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
                padding:
                    const EdgeInsets.fromLTRB(16, 20, 16, 28),
                child: Column(
                  children: [
                    // ── Provider Summary Card ───────────
                    _ProviderSummaryCard(
                      name: name,
                      category:
                          provider.category?.categoryName ?? '',
                      imageUrl: imageUrl,
                      initials: _initials(name),
                      pricePerHour: provider.pricePerHour,
                    ),

                    const SizedBox(height: 16),

                    // ── Booking Details Card ────────────
                    _FormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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

                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(
                                    title: 'Schedule'),
                                const SizedBox(height: 12),

                                // Date + Time row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _DateTimeButton(
                                        icon: Icons
                                            .calendar_today_outlined,
                                        label: 'Date',
                                        value: _selectedDate != null
                                            ? DateFormat('MMM d, yyyy')
                                                .format(_selectedDate!)
                                            : null,
                                        placeholder: 'Select date',
                                        onTap: _pickDate,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _DateTimeButton(
                                        icon: Icons.access_time_rounded,
                                        label: 'Time',
                                        value: _selectedTime != null
                                            ? _selectedTime!
                                                .format(context)
                                            : null,
                                        placeholder: 'Select time',
                                        onTap: _pickTime,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                                const _SectionTitle(title: 'Location'),
                                const SizedBox(height: 10),
                                _InputField(
                                  controller: _addressController,
                                  hintText: 'Enter your address',
                                  icon: Icons.location_on_outlined,
                                  maxLines: 2,
                                ),

                                const SizedBox(height: 20),
                                const _SectionTitle(title: 'Note'),
                                const SizedBox(height: 10),
                                _InputField(
                                  controller: _noteController,
                                  hintText:
                                      'Any additional instructions (optional)',
                                  icon: Icons.notes_rounded,
                                  maxLines: 3,
                                ),

                                const SizedBox(height: 20),
                                SeveritySelector(
                                  selectedSeverity: _severity,
                                  onChanged: (v) =>
                                      setState(() => _severity = v),
                                ),

                                const SizedBox(height: 24),

                                // Price preview
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFFFFF7ED),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(
                                            0xFFFFDDCC)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Effective Rate',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _textSecondary,
                                              fontWeight:
                                                  FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Base: NPR ${provider.pricePerHour.toStringAsFixed(0)}/hr',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFADB5BD),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'NPR ${_effectivePrice.toStringAsFixed(0)}/hr',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: _orange,
                                          letterSpacing: -0.5,
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
                    ),
                  ],
                ),
              ),
            ),

            // ── Submit Button ─────────────────────────
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: state.status == BookingStatus.loading
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          _orange.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: state.status == BookingStatus.loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Review Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
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
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _ProviderSummaryCard extends StatelessWidget {
  final String name;
  final String category;
  final String imageUrl;
  final String initials;
  final double pricePerHour;

  const _ProviderSummaryCard({
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.initials,
    required this.pricePerHour,
  });

  static const _orange = Color(0xFFFF6B35);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFFFF3EE),
              border:
                  Border.all(color: const Color(0xFFFFDDCC), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: _orange)),
                        ))
                : Center(
                    child: Text(initials,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _orange)),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary)),
                if (category.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(category,
                      style: const TextStyle(
                          fontSize: 13,
                          color: _orange,
                          fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          Text(
            'NPR ${pricePerHour.toStringAsFixed(0)}/hr',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _orange),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

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
              blurRadius: 12,
              offset: Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: -0.2),
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  const _DateTimeButton({
    required this.icon,
    required this.label,
    this.value,
    required this.placeholder,
    required this.onTap,
  });

  static const _orange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: hasValue
              ? const Color(0xFFFFF7ED)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                hasValue ? const Color(0xFFFFDDCC) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: hasValue ? _orange : const Color(0xFF9CA3AF)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    value ?? placeholder,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasValue
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFD1D5DB),
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
            color: Color(0xFFD1D5DB), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFFF6B35), width: 2),
        ),
      ),
    );
  }
}