import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ImageableContainer extends StatelessWidget {
  final ImageableController controller;

  final Color color;

  final List<Widget> children;

  const ImageableContainer({
    super.key,
    required this.controller,
    this.color = const Color(0xFFFFFFFF),
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: RepaintBoundary(
          key: controller.key,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
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
    );
  }
}

class ImageableController {
  final GlobalKey key;

  /// How many pixels in a row
  final double rowSize;

  ImageableController({
    required this.key,
    this.rowSize = 384,
  });

  Future<Uint8List?> toImage() async {
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }

    final image = await boundary.toImage(pixelRatio: rowSize / boundary.paintBounds.width);
    final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
    final bytes = byteData?.buffer.asUint8List();
    final result = _luminosityWeighted(bytes!);
    print('get image size: ${result.length} if width is $rowSize, the height is ${result.length / rowSize}');

    return result;
  }

  /// see: https://en.wikipedia.org/wiki/Luma_%28video%29#Rec._601_luma_versus_Rec._709_luma_coefficients
  /// bit map should follow floyd-steinberg
  Uint8List _luminosityWeighted(Uint8List bytes) {
    final size = bytes.length ~/ 4;
    final result = Uint8List(size);
    for (var i = 0; i < size; i += 4) {
      final r = bytes[i];
      final g = bytes[i + 1];
      final b = bytes[i + 2];
      result[i ~/ 4] = (r * 0.299 + g * 0.587 + b * 0.114).round();
    }
    return result;
  }
}
