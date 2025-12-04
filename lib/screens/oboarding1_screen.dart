import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sewa_hub/widget/button1.dart';
import 'package:sewa_hub/widget/button2.dart';

class Oboarding1Screen extends StatelessWidget {
  const Oboarding1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Column(
          children: [
            SizedBox(height: 120,),
            Image.asset('assets/images/onboarding1.png',fit:BoxFit.contain),
            SizedBox(height: 10,),
            Text('Your Home,Our',style:TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35
            ),),
            Text('Services.',style:TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35
            ),),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Discover a comprehensive range of services tailored for you.',
              textAlign: TextAlign.center,
              style:TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 20,
                color: const Color.fromARGB(255, 103, 103, 103)
              ),),
            ),
            SizedBox(height: 10,),
            Button2(text: "Get Started"),
            // Button1(text: "Login",)
          ],
        ),
    );
  }
}