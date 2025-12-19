import 'package:flutter/material.dart';

class ServiceIncludedCard extends StatelessWidget {
  const ServiceIncludedCard({
    super.key,
    required this.text,
    required this.fontSize, // pass font size
    required this.horizontalPadding, // optional: scale padding
    required this.verticalPadding,
  });

  final String text;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
