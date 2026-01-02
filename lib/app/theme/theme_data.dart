import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
    fontFamily: 'Inter Regular',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter Bold',
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: const IconThemeData(color: Color(0xFFFF7940)),
      unselectedIconTheme: const IconThemeData(color: Colors.black),
      selectedItemColor: const Color(0xFFFF7940),
      unselectedItemColor: Colors.black, 
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      elevation: 10.0
    ),
  );
}
