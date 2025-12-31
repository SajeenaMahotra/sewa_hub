import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Button2 extends StatelessWidget {
  const Button2({super.key,
  required this.text,
  required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7940),
            padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              )
          ),onPressed: onPressed, child: 
        Text(text,
        style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
        )),
      ),
    );
  }
}