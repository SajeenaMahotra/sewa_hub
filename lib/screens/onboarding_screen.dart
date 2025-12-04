import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sewa_hub/widget/onboardingpage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                onboardingPage(
                  topSpace: 100,
                  imagePath: 'assets/images/onboarding1.png',
                ),
                onboardingPage(
                  topSpace: 160,
                  imagePath: 'assets/images/onboarding2.png',
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentPage == 0 ? Color(0xFFFF7940) : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                margin: EdgeInsets.all(4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentPage == 1 ? Color(0xFFFF7940) : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
