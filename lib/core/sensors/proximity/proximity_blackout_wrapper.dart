import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/sensors/proximity/proximity_service.dart';

/// Wrap this around your app's home/dashboard.
/// When phone is near pocket → blacks out screen.
/// When moved away → screen comes back instantly.
class ProximityBlackoutWrapper extends ConsumerWidget {
  final Widget child;
  const ProximityBlackoutWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBlackedOut = ref.watch(isScreenBlackedOutProvider);

    return Stack(
      children: [
        child,

        // ── Black overlay ──────────────────────────────────────────────
        if (isBlackedOut)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity:  isBlackedOut ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child:    Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.screen_lock_portrait_rounded,
                    color:  Colors.white24,
                    size:   48,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}