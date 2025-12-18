import 'package:flutter/material.dart';

class ButtonOutline extends StatelessWidget {
  const ButtonOutline({super.key, required this.text, required this.onPressed});

   final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFF7940)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFFF7940),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}