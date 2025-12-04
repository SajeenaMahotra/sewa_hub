import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Button1 extends StatelessWidget {
  const Button1({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
        ),
        onPressed: () {}, child: Text(text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 25
        ),)),
      ),
    );
  }
}