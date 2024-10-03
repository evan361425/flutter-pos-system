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
  final int width;

  ImageableController({
    required this.key,
    this.width = 384,
  });

  Future<Uint8List?> toImage({
    bool invertBits = false,
  }) async {
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }

    final image = await boundary.toImage(pixelRatio: width / boundary.paintBounds.width);
    final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
    final bytes = byteData!.buffer.asUint8List();
    final result = _luminosityWeighted(bytes, invertBits);

    return result;
  }

  /// First convert to gray-scale then convert to binary image
  /// gray-scale see: https://en.wikipedia.org/wiki/Luma_%28video%29#Rec._601_luma_versus_Rec._709_luma_coefficients
  /// floyd-steinberg dithering see: https://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering
  Uint8List _luminosityWeighted(Uint8List bytes, bool invertBits) {
    // convert to gray-sale (4 bytes to 1 byte)
    final gray = Uint8List(bytes.length ~/ 4);
    for (var i = 0; i < bytes.length; i += 4) {
      final r = bytes[i];
      final g = bytes[i + 1];
      final b = bytes[i + 2];
      gray[i] = (r * 0.299 + g * 0.587 + b * 0.114).round();
    }
    // binary image (byte to bit)
    final result = Uint8List(gray.length ~/ 8);
    final lastRow = gray.length - width;
    for (var i = 0; i < gray.length; i++) {
      // convert to binary image
      final p = gray[i] > 127.5 ? 1 : 0;
      final err = gray[i] - p * 255;
      if (invertBits) {
        result[i ~/ 8] |= p << (i % 8);
      } else {
        result[i ~/ 8] |= p << (7 - i % 8);
      }

      // floyd-steinberg dithering
      if (i % width == width - 1) {
        gray[i] += err * 7 ~/ 16;
      }

      if (i < lastRow) {
        gray[i + width - 1] += err * 3 ~/ 16;
        gray[i + width] += err * 5 ~/ 16;
        gray[i + width + 1] += err ~/ 16;
      }
    }
    return result;
  }
}
