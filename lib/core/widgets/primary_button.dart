import 'package:flutter/material.dart';

/// A reusable gradient action button used across the app.
///
/// Usage:
/// ```dart
/// PrimaryButton(label: 'Book now', onTap: () {})
///
/// // Full width (standalone context):
/// SizedBox(width: double.infinity, child: PrimaryButton(label: 'Submit', onTap: () {}))
/// ```
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  /// Gradient colors — defaults to the app's brand orange.
  final List<Color> gradientColors;

  /// Padding inside the button.
  final EdgeInsetsGeometry padding;

  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradientColors = const [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    this.borderRadius = 30,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ✅ NO width: double.infinity — parent decides the width.
        // Wrap with SizedBox(width: double.infinity) when full-width is needed.
        padding: padding,
        alignment: Alignment.center,
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
          textAlign: TextAlign.center,
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