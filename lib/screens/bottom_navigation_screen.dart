import 'package:flutter/cupertino.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [];
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}