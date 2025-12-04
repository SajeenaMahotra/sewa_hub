import 'package:flutter/material.dart';
import 'package:sewa_hub/screens/oboarding1_screen.dart';
import 'package:sewa_hub/screens/onboarding2_screen.dart';
import 'package:sewa_hub/screens/onboarding_screen.dart';
import 'package:sewa_hub/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}