import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.022)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class DiagonalAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7F77DD).withOpacity(0.07)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 6; i++) {
      final offset = i * 18.0;
      canvas.drawLine(Offset(offset, 0), Offset(0, offset), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
