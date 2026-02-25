import 'package:flutter/material.dart';

/// A reusable gradient action button used across the app.
///
/// Usage:
/// ```dart
/// PrimaryButton(
///   label: 'Book now',
///   onTap: () {},
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  /// Gradient colors — defaults to the app's brand orange.
  final List<Color> gradientColors;

  /// Horizontal padding inside the button.
  final EdgeInsetsGeometry padding;

  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradientColors = const [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
    this.borderRadius = 30,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w700,
  });

  @override
  @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,          // ← always fill horizontal space
      padding: padding,
      alignment: Alignment.center,     // ← center children
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: 0.2,
        ),
      ),
    ),
  );
}
}