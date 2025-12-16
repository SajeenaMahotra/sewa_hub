import 'package:flutter/material.dart';

ThemeData getApplicationTheme(){
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
    fontFamily: 'Inter Regular',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter Bold'
        ),
        
      )
    )
  );
}