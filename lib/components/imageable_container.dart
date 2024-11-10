import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/logger.dart';

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
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing, vertical: kTopSpacing),
        child: SingleChildScrollView(
          child: DefaultTextStyle(
            style: const TextStyle(color: Color(0xFF424242), overflow: TextOverflow.clip),
            child: RepaintBoundary(
              key: controller.key,
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

/// Manage the imageable container
class ImageableManger {
  static ImageableManger instance = ImageableManger();

  /// Make testing easy
  ImageableController create() => ImageableController(key: GlobalKey());
}

class ImageableController {
  final GlobalKey key;

  ImageableController({required this.key});

  /// Convert the widget to an image
  ///
  /// - [asPng] is true, the image will be in PNG format, otherwise, it will be in raw RGBA format
  /// - [widths] tells how many pixels in a row, can provide multiple values to get multiple images
  Future<List<ConvertibleImage>?> toImage({
    required List<int> widths,
  }) async {
    // Delay is required. See Issue https://github.com/flutter/flutter/issues/22308
    await Future.delayed(const Duration(milliseconds: 20));

    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }

    final result = <ConvertibleImage>[];
    for (final w in widths) {
      final image = await boundary.toImage(pixelRatio: w / boundary.paintBounds.width);
      final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
      result.add(ConvertibleImage(byteData!.buffer.asUint8List(), width: w));
      Log.out('generate image with width: $w', 'imageable_container');

      image.dispose();
    }

    return result;
  }
}

class ConvertibleImage {
  final Uint8List bytes;

  final int width;

  const ConvertibleImage(this.bytes, {required this.width});

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

    return ConvertibleImage(result, width: width);
  }

  /// Black is 0, White is 1
  ///
  /// If [mirrored] is true, the bits will be mirrored, for example, 10000000 will be 00000001
  /// If [invert] is true, black will be 1, white will be 0
  ConvertibleImage toBitMap({bool mirrored = true, bool invert = true}) {
    // 8 bits to 1 bit
    final result = Uint8List(bytes.length ~/ 8);
    for (var i = 0; i < bytes.length; i++) {
      // convert to binary image
      final write = invert
          ? bytes[i] > 0 // black
          : bytes[i] == 0; // white
      if (write) {
        if (mirrored) {
          result[i ~/ 8] |= 1 << (i % 8);
        } else {
          result[i ~/ 8] |= 1 << (7 - i % 8);
        }
      }
    }

    return ConvertibleImage(result, width: width);
  }
}
