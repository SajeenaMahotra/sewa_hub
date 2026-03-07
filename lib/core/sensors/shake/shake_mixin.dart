import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/sensors/shake/shake_detector_service.dart';

/// Mix this into any ConsumerState to get shake detection.
/// Just override [onShakeDetected] and call [initShake] in initState.
mixin ShakeMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _shakeInitialized = false;

  void initShake() {
    if (_shakeInitialized) return;
    _shakeInitialized = true;

    final service = ref.read(shakeDetectorServiceProvider);
    service.onShake = () {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) onShakeDetected();
        });
      }
    };
    service.start();
  }

  /// Override this in your screen
  void onShakeDetected();

  @override
  void dispose() {
    ref.read(shakeDetectorServiceProvider).onShake = null;
    super.dispose();
  }
}
