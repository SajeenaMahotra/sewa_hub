import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

final shakeDetectorServiceProvider = Provider<ShakeDetectorService>((ref) {
  final service = ShakeDetectorService();
  ref.onDispose(() => service.dispose());
  return service;
});

class ShakeDetectorService {
  static const double _shakeThreshold   = 15.0; // m/s² — tweak if too sensitive
  static const int    _minTimeBetweenMs  = 5000; // cooldown between shakes

  int _lastShakeTime = 0;

  /// Called when a shake is confirmed
  VoidCallback? onShake;

  void start() {
    accelerometerEventStream().listen(_onAccelerometerEvent);
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Remove gravity (~9.8 m/s²)
    final force = (magnitude - 9.8).abs();

    if (force > _shakeThreshold) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastShakeTime > _minTimeBetweenMs) {
        _lastShakeTime = now;
        debugPrint('[Shake] Detected! force=$force');
        onShake?.call();
      }
    }
  }

  void dispose() {
    onShake = null;
  }
}