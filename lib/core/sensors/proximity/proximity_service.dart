import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

// ── Provider 
final proximityServiceProvider = Provider<ProximityService>((ref) {
  final service = ProximityService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ── Is screen blacked out ─────────────────────────────────────────────────────
final isScreenBlackedOutProvider = StateProvider<bool>((ref) => false);

class ProximityService {
  StreamSubscription<int>? _subscription;

  Future<void> start(WidgetRef ref) async {
    try {

      _subscription = ProximitySensor.events.listen((int event) {
        // event == 1 → near, event == 0 → far (open)
        final isNear = event == 1;
        ref.read(isScreenBlackedOutProvider.notifier).state = isNear;
      });
    } catch (e) {
      debugPrint('[Proximity] Error: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}