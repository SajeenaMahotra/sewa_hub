import 'package:flutter/material.dart';

class DottedBackground extends StatelessWidget {
  final Widget child;
  const DottedBackground({super.key, required this.child});

  @override
Widget build(BuildContext context) {
  return Container(
    color: const Color(0xFFFAF9F7),  // ← add this
    child: CustomPaint(
      painter: _DotPainter(),
      child: child,
    ),
  );
}
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5E0D8)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    const radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}