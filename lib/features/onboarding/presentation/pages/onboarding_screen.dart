import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sewa_hub/screens/login_screen.dart';
import 'package:sewa_hub/screens/signup_screen.dart';
import 'package:sewa_hub/features/onboarding/presentation/view_model/onboarding_viewmodel.dart';
import 'package:sewa_hub/core/widgets/button1.dart';
import 'package:sewa_hub/core/widgets/button2.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewmodel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: Consumer<OnboardingViewmodel>(
                    builder: (context, viewModel, _) {
                      return PageView(
                        controller: viewModel.controller,
                        onPageChanged: (index) {
                          viewModel.setCurrentPage(index);
                        },
                        children: [
                          _buildPage(
                            imagePath: 'assets/images/onboarding1.png',
                            topSpace: 120,
                            title1: 'Your Home,Our',
                            title2: 'Services.',
                            subtitle:
                                'Discover a comprehensive range of services tailored for you.',
                          ),
                          _buildPage(
                            imagePath: 'assets/images/onboarding2.png',
                            topSpace: 120,
                            title1: 'Book Smarter,',
                            title2: 'Live Easier.',
                            subtitle:
                                'Schedule your services in just a few taps.',
                          ),
                          _buildPage(
                            imagePath: 'assets/images/onboarding3.png',
                            topSpace: 120,
                            title1: 'Trust in Every',
                            title2: 'Service.',
                            subtitle:
                                'Reliable support from verified experts — simple, secure, hassle-free.',
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Fixed dots and buttons
                Consumer<OnboardingViewmodel>(
                  builder: (context, viewModel, _) {
                    return Column(
                      children: [
                        // Dots
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin: const EdgeInsets.all(4),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: viewModel.currentPage == index
                                      ? const Color(0xFFFF7940)
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height:0),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0,right: 10, left: 10),
                          child: Button2(
                            text: "Get Started",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String imagePath,
    required double topSpace,
    required String title1,
    required String title2,
    required String subtitle,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: topSpace),
          Image.asset(imagePath, fit: BoxFit.contain),
          const SizedBox(height: 10),
          Text(
            title1,
            style: const TextStyle( fontFamily: 'Inter Bold', fontSize: 35),
          ),
          Text(
            title2,
            style: const TextStyle(fontFamily: 'Inter Bold', fontSize: 35),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
