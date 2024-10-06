import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/constants/constant.dart';

class ImageableContainer extends StatelessWidget {
  final ImageableController controller;

  final List<Widget> children;

  const ImageableContainer({
    super.key,
    required this.controller,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: DefaultTextStyle(
          style: const TextStyle(color: Color(0xFF424242)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing, vertical: kTopSpacing),
            constraints: const BoxConstraints(maxWidth: 600),
            child: RepaintBoundary(
              key: controller.key,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
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

  /// How many pixels in a row
  final int width;

  ImageableController({
    required this.key,
    this.width = 384,
  });

  Future<ConvertibleImage?> toImage() async {
    // Delay is required. See Issue https://github.com/flutter/flutter/issues/22308
    await Future.delayed(const Duration(milliseconds: 20));

    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }

    final image = await boundary.toImage(pixelRatio: width / boundary.paintBounds.width);
    final byteData = await image.toByteData();
    final result = ConvertibleImage(byteData!.buffer.asUint8List());

    image.dispose();
    return result;
  }
}

class ConvertibleImage {
  final Uint8List bytes;

  const ConvertibleImage(this.bytes);

  /// see: https://en.wikipedia.org/wiki/Luma_%28video%29#Rec._601_luma_versus_Rec._709_luma_coefficients
  ConvertibleImage toGrayScale() {
    // 4 bytes to 1 byte
    final result = Uint8List(bytes.length ~/ 4);
    for (var i = 0; i < bytes.length; i += 4) {
      final r = bytes[i];
      final g = bytes[i + 1];
      final b = bytes[i + 2];
      result[i ~/ 4] = (r * 0.299 + g * 0.587 + b * 0.114).round();
    }

    return ConvertibleImage(result);
  }

  /// see: https://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering
  ConvertibleImage toBitMap({required int width, bool invertBits = false, bool blackIsOne = false}) {
    // 8 bits to 1 bit
    final result = Uint8List(bytes.length ~/ 8);
    final lastRow = bytes.length - width;
    for (var i = 0; i < bytes.length; i++) {
      // convert to binary image
      var err = bytes[i];
      if (bytes[i] > 127) {
        err = bytes[i] - 255;
        if (invertBits) {
          result[i ~/ 8] |= 1 << (i % 8);
        } else {
          result[i ~/ 8] |= 1 << (7 - i % 8);
        }
      }

      // floyd-steinberg dithering
      if (i % width < width - 1) {
        bytes[i + 1] += err * 7 ~/ 16;
        if (i < lastRow) {
          bytes[i + width + 1] += err ~/ 16;
        }
      }

      if (i < lastRow) {
        bytes[i + width - 1] += err * 3 ~/ 16;
        bytes[i + width] += err * 5 ~/ 16;
      }
    }

    if (blackIsOne) {
      return ConvertibleImage(Uint8List.fromList(result.map((e) => ~e).toList()));
    }

    return ConvertibleImage(result);
  }
}
