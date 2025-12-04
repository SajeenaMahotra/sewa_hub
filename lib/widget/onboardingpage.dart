import 'package:flutter/material.dart';

Widget onboardingPage({required double topSpace, required String imagePath}) {
  return Column(
    children: [
      SizedBox(height: topSpace),
      Image.asset(imagePath, fit: BoxFit.contain),
      SizedBox(height: 10),

      Text(
        'Your Home,Our',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
      ),
      Text(
        'Services.',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
      ),

      SizedBox(height: 20),

      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Discover a comprehensive range of services tailored for you.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 20,
            color: Color.fromARGB(255, 103, 103, 103),
          ),
        ),
      ),
    ],
  );
}