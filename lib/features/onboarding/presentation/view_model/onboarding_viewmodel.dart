import 'package:flutter/material.dart';

class OnboardingViewmodel extends ChangeNotifier {
  int _currentPage = 0;
  late PageController _pagecontroller;

  int get currentPage => _currentPage;
  PageController get controller => _pagecontroller;

  OnboardingViewmodel() {
    _pagecontroller = PageController();
  }

  void setCurrentPage(int index) {
    _currentPage = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _pagecontroller.dispose();
    super.dispose();
  }
}