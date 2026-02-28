import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/app/theme/theme_data.dart';
import 'package:sewa_hub/core/sensors/shake/shake_detector_service.dart';
import 'package:sewa_hub/core/sensors/shake/emergency_booking_dialog.dart';
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:sewa_hub/features/splash/presentation/pages/splash_screen.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initShake();
    });
  }

  void _initShake() {
  final service = ref.read(shakeDetectorServiceProvider);
  service.onShake = () {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    final session = ref.read(userSessionServiceProvider);
    if (!session.isLoggedIn()) return;
    showEmergencyBookingDialog(ctx); // ← call directly, no wrapper
  };
  service.start();
}

  @override
  void dispose() {
    ref.read(shakeDetectorServiceProvider).onShake = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey, // ← key to get context anywhere
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: const SplashScreen(),
    );
  }
}