import 'package:flutter/material.dart';
import 'package:sewa_hub/screens/onboarding_screen.dart';
import 'package:sewa_hub/screens/splash_screen.dart';
import 'package:sewa_hub/theme/theme_data.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: const SplashScreen(),
    );
  }
}
