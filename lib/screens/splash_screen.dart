import 'package:flutter/material.dart';
import 'package:sewa_hub/features/onboarding/presentation/pages/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override

  void initState(){
    super.initState();
    _navigateToOnboarding();
  }

  void _navigateToOnboarding(){
    Future.delayed(const Duration(seconds: 2),() {
      if (mounted) {
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()));
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          height:100,// MediaQuery.of(context).size.height*.5,
          width: 250,//MediaQuery.of(context).size.height*.5,
          child: Image.asset('assets/images/sewahub_logo.png',fit:BoxFit.contain),
        ),
      ),
    );
  }
}