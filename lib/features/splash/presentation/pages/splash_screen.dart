import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/app/routes/app_routes.dart';
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:sewa_hub/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:sewa_hub/features/onboarding/presentation/pages/onboarding_page.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override

  void initState(){
    super.initState();
    _navigateToOnboarding();
  }

  void _navigateToOnboarding(){
    Future.delayed(const Duration(seconds: 2),() {
      if ( !mounted ) return; 
      final userSessionService = ref.read(userSessionServiceProvider);
      final isLoggedIn = userSessionService.isLoggedIn();

      if(isLoggedIn){
        AppRoutes.pushReplacement(context, const DashboardScreen());
      } else{
        AppRoutes.pushReplacement(context, const OnboardingScreen());
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