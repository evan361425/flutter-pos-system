import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/image.dart';

class ImageableContainer extends StatelessWidget {
  static const paddingWidth = 28.0; // 10 * 2 + 4 * 2 (padding + margin)

  final ImageableController controller;

  final TextStyle style;

  final List<Widget> children;

  const ImageableContainer({super.key, required this.controller, required this.style, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const .symmetric(horizontal: 10.0, vertical: 12.0),
        child: SingleChildScrollView(
          // DefaultTextStyle only work here, not work outside settings
          child: DefaultTextStyle.merge(
            style: style,
            child: RepaintBoundary(
              key: controller.key,
              child: Column(mainAxisSize: .min, crossAxisAlignment: .stretch, children: children),
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
  Future<List<RGBImage>?> toImage({required List<int> widths}) async {
    // Delay is required. See Issue https://github.com/flutter/flutter/issues/22308
    await Future.delayed(const Duration(milliseconds: 20));

    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }

    final result = <RGBImage>[];
    for (final w in widths) {
      final ratio = w / boundary.size.width;
      assert(
        (boundary.size.width * ratio).ceil() == w,
        'Float error: ${boundary.size.width} * $ratio = ${boundary.size.width * ratio}, '
        'ceil would give ${(boundary.size.width * ratio).ceil()} instead of $w.',
      );

      // Scaling by a float pixelRatio can introduce ceiling error (e.g. 384.001 -> ceil -> 385).
      // It is fine for the fixed 320 -> 384 sizes used here; recheck if they change.
      final image = await boundary.toImage(pixelRatio: ratio);
      final byteData = await image.toByteData(format: .rawRgba);
      result.add(RGBImage(byteData!.buffer.asUint8List(), width: w));
      Log.out('generate image with width: $w', 'imageable_container');

      image.dispose();
    }

    return result;
  }
}
