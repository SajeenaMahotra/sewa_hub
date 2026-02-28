import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/features/booking/domain/usecases/create_booking_usecase.dart';

Future<void> showRatingDialog(
  BuildContext context,
  WidgetRef ref, {
  required String bookingId,
  String providerName = 'the provider',
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RatingSheet(
      bookingId: bookingId,
      providerName: providerName,
      ref: ref,
    ),
  );
}

class _RatingSheet extends StatefulWidget {
  final String bookingId;
  final String providerName;
  final WidgetRef ref;

  const _RatingSheet({
    required this.bookingId,
    required this.providerName,
    required this.ref,
  });

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  static const _orange = Color(0xFFFF6B35);

  int  _selected  = 0;    // 0 = none chosen yet
  bool _submitted = false;
  bool _loading   = false;

  static const _labels = ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'];

  Future<void> _submit() async {
    if (_selected == 0) return;
    setState(() => _loading = true);

    final usecase = widget.ref.read(rateProviderUsecaseProvider);
    final result  = await usecase(
        RateProviderParams(bookingId: widget.bookingId, rating: _selected));

    if (!mounted) return;
    setState(() => _loading = false);

    result.fold(
      (failure) => SnackbarUtils.showError(context,
          message: failure.message),
      (_) {
        setState(() => _submitted = true);
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) Navigator.pop(context);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: _submitted ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎉', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        const Text('Thank you!',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
        const SizedBox(height: 6),
        Text('Your rating for ${widget.providerName} has been submitted.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle
        Container(
          width: 40, height: 4,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        Text(
          'Rate ${widget.providerName}',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3),
        ),
        const SizedBox(height: 6),
        const Text(
          'How was your experience?',
          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),

        const SizedBox(height: 24),

        // Stars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final star = i + 1;
            return GestureDetector(
              onTap: () => setState(() => _selected = star),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Icon(
                  star <= _selected ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: star <= _selected ? 48 : 40,
                  color: star <= _selected ? Colors.amber : Colors.grey.shade300,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        // Label + emoji
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _selected > 0
              ? Text(
                  '${_labels[_selected]}',
                  key: ValueKey(_selected),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A)),
                )
              : const Text(
                  'Tap a star to rate',
                  key: ValueKey(0),
                  style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                ),
        ),

        const SizedBox(height: 28),

        // Submit
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _selected == 0 || _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor:         _orange,
              foregroundColor:         Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              disabledForegroundColor: Colors.grey,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _loading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : const Text('Submit Rating',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),

        const SizedBox(height: 10),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Skip',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
        ),
      ],
    );
  }
}