import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/sensors/proximity/proximity_service.dart';
import 'package:sewa_hub/core/sensors/proximity/proximity_blackout_wrapper.dart';
import 'package:sewa_hub/features/dashboard/presentation/pages/my_booking_page.dart';
import 'package:sewa_hub/features/dashboard/presentation/pages/chat_screen.dart';
import 'package:sewa_hub/features/dashboard/presentation/pages/home_screen.dart';
import 'package:sewa_hub/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:sewa_hub/core/widgets/dotted_background.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyBookingsPage(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded,        outlinedIcon: Icons.home_outlined,           label: 'Home'),
    _NavItem(icon: Icons.calendar_month,      outlinedIcon: Icons.calendar_month_outlined,  label: 'Booking'),
    _NavItem(icon: Icons.chat_bubble_rounded, outlinedIcon: Icons.chat_bubble_outline,      label: 'Chat'),
    _NavItem(icon: Icons.person_rounded,      outlinedIcon: Icons.person_outline_rounded,   label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    // ← Start proximity sensor when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proximityServiceProvider).start(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProximityBlackoutWrapper(  // ← wraps everything
      child: DottedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _screens[_selectedIndex],
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset:     const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFF0EDE8), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item     = _navItems[index];
              final selected = _selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap:    () => setState(() => _selectedIndex = index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:  const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 3),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFFF7940).withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            selected ? item.icon : item.outlinedIcon,
                            color: selected
                                ? const Color(0xFFFF7940)
                                : const Color(0xFF9E9E9E),
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize:   11,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: selected
                                ? const Color(0xFFFF7940)
                                : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData outlinedIcon;
  final String   label;
  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
  });
}