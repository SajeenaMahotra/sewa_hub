import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Button1 extends StatelessWidget {
  const Button1({
    super.key,
    required this.logoPath,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    required this.logoSize,
  });


  final String logoPath;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(12),
            child: 
              Image.asset(logoPath,
          ),
        ),
      ),
    );
  }
}
