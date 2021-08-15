import 'package:flutter/material.dart';

// https://stackoverflow.com/a/58352984/12089368
class TipShapeBorder extends ShapeBorder {
  final double arrowWidth;

  final double arrowHeight;

  /// Arc of arrow
  ///
  /// Should between `1` and `0`
  final double arrowArc;

  final double radius;

  final Offset target;

  TipShapeBorder({
    required this.target,
    this.radius = 4.0,
    this.arrowWidth = 20.0,
    this.arrowHeight = 10.0,
    this.arrowArc = 0.0,
  }) : assert(arrowArc <= 1.0 && arrowArc >= 0.0);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(
      rect.topLeft,
      rect.bottomRight - Offset(0, arrowHeight),
    );
    if (rect.top == 0 && rect.left == 0) {
      return Path();
    }

    final isDown = target.dy > rect.top;
    final x = arrowWidth, r = 1 - arrowArc;
    final y = isDown ? arrowHeight : -arrowHeight;

    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(target.dx + arrowWidth / 2, isDown ? rect.bottom : rect.top)
      ..relativeLineTo(-x / 2 * r, y * r)
      ..relativeQuadraticBezierTo(
          -x / 2 * (1 - r), y * (1 - r), -x * (1 - r), 0)
      ..relativeLineTo(-x / 2 * r, -y * r);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
