import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sewa_hub/widget/button1.dart';
import 'package:sewa_hub/widget/button2.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Column(
          children: [
            SizedBox(height: 160,),
            Image.asset('assets/images/onboarding2.png',fit:BoxFit.contain),
            SizedBox(height: 10,),
            Text('Book Smarter,',style:TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35
            ),),
            Text('Live Easier.',style:TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35
            ),),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Schedule your services in just a few taps.',
              textAlign: TextAlign.center,
              style:TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 20,
                color: const Color.fromARGB(255, 103, 103, 103)
              ),),
            ),
            SizedBox(height: 10,),
            Button2(text: "Sign Up"),
            Button1(text: "Login",)
          ],
      ),
    );
  }
}