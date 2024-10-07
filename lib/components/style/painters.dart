import 'dart:math' show tan, pi;

import 'package:flutter/widgets.dart';

class ZigZagPainter extends CustomPainter {
  /// How deep the zigzag will be.
  ///
  /// Also the height of the zigzag if you place it horizontally.
  final double depth;

  /// Angle of the zigzag corner.
  ///
  /// Smaller angle will have more zigzag but each zigzag will be smaller.
  final double angle;

  /// Width of the zigzag line.
  final double strokeWidth;

  /// Color of the zigzag line.
  final Color color;

  const ZigZagPainter({
    this.angle = 60,
    this.depth = 6.0,
    this.strokeWidth = 1.0,
    this.color = const Color(0xFF000000),
  }) : assert(angle > 0 && angle < 180);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..style = PaintingStyle.stroke;

    final zw = angle == 90.0 ? depth : (depth * tan(angle / 360 * pi));
    final zl = zw * 2;
    final count = size.width ~/ zl;

    if (count == 0) {
      final yOffset = strokeWidth / 2;

      canvas.drawLine(Offset(0, yOffset), Offset(size.width, yOffset), paint);
      return;
    }

    // start points will add padding for remaining space
    var offset = (size.width % zl) / 2;
    final path = Path()
      ..addPolygon(<Offset>[
        Offset(offset, depth / 2),
        Offset(offset += zw / 2, 0.0),
        Offset(offset += zw, depth),
        for (int i = 2; i <= count; i++) ...[
          Offset(offset, depth),
          Offset(offset += zw, 0.0),
          Offset(offset += zw, depth),
        ],
        Offset(offset, depth),
        Offset(offset + zw / 2, depth / 2),
      ], false);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
