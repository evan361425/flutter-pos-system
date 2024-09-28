import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ImageableContainer extends StatelessWidget {
  final ImageableController controller;

  /// The width of the paper in millimeters.
  final double paperWidthMm;

  final Color color;

  final List<Widget> children;

  const ImageableContainer({
    super.key,
    required this.controller,
    this.paperWidthMm = 58.0,
    this.color = const Color(0xFFFFFFFF),
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: RepaintBoundary(
            key: controller.key,
            child: Container(
              width: paperWidthMm * _dpPerMm,
              color: color,
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageableController {
  final GlobalKey key;

  ImageableController({required this.key});

  Future<Uint8List> toImage() async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }
}

/// Per device-independent pixel is 0.15875 mm
/// see: https://en.wikipedia.org/wiki/Device-independent_pixel
const _dpPerMm = 6.299;
