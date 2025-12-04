import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          height:100,// MediaQuery.of(context).size.height*.5,
          width: 250,//MediaQuery.of(context).size.height*.5,
          child: Image.asset('assets/images/sewahub_logo.png',fit:BoxFit.contain),
        ),
      ),
    );
  }
}