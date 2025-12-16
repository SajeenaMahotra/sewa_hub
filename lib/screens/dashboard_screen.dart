import 'package:flutter/material.dart';
import 'package:sewa_hub/screens/bottom_screen/booking_screen.dart';
import 'package:sewa_hub/screens/bottom_screen/chat_screen.dart';
import 'package:sewa_hub/screens/bottom_screen/home_screen.dart';
import 'package:sewa_hub/screens/bottom_screen/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const BookingScreen(),
    const ChatScreen(),
    const ProfileScreen()
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const[
        BottomNavigationBarItem(icon: Icon(Icons.home),
        label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.check_box),
        label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.chat),
        label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person),
        label: 'Profile')
      ],
      currentIndex: _selectedIndex,
      onTap: (index){
        setState(() {
          _selectedIndex = index;
        });
      }),
    );
  }
}