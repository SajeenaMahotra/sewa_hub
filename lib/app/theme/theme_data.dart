import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF7940)),
    fontFamily: 'Inter Regular',
    scaffoldBackgroundColor: const Color(0xFFFAF9F7),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF7940),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter Bold',
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedIconTheme: IconThemeData(color: Color(0xFFFF7940), size: 24),
      unselectedIconTheme: IconThemeData(color: Color(0xFF9E9E9E), size: 22),
      selectedItemColor: Color(0xFFFF7940),
      unselectedItemColor: Color(0xFF9E9E9E),
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11,
        fontFamily: 'Inter Bold',
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 11,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}