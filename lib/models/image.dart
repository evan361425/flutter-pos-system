import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

abstract class ImageBytes {
  final Uint8List bytes;

  final int width;

  const ImageBytes(this.bytes, {required this.width});
}

class ConstantImage extends ImageBytes {
  const ConstantImage(super.bytes, {required super.width});
}

class RGBImage extends ImageBytes {
  const RGBImage(super.bytes, {required super.width});

  /// Convert RGBA image to gray-scale (8‑bit luminance) using Rec.601 coefficients.
  GrayImage toGrayScale() {
    final result = Uint8List(bytes.length ~/ 4);
    for (int i = 0; i < result.length; i++) {
      result[i] = _pixelToLuminance(i * 4);
    }
    return GrayImage(result, width: width);
  }

  /// Adaptive (local) thresholding to produce a 1-bit binary from RGBA.
  GrayImage toDocBinary({int blockSize = 15, int c = 10}) {
    assert(blockSize % 2 == 1, 'blockSize must be odd');
    final half = blockSize ~/ 2;
    final height = bytes.length ~/ width ~/ 4;

    // 1. Build integral image for fast mean calculation directly from RGBA
    final List<int> integral = .filled((height + 1) * (width + 1), 0);
    for (int y = 1; y <= height; y++) {
      int rowSum = 0;
      final int rowOffset = (y - 1) * width * 4;
      for (int x = 1; x <= width; x++) {
        final int pixelOffset = rowOffset + (x - 1) * 4;
        rowSum += _pixelToLuminance(pixelOffset);
        integral[y * (width + 1) + x] = integral[(y - 1) * (width + 1) + x] + rowSum;
      }
    }

    // 2. Compute thresholding
    final Uint8List result = Uint8List(width * height);
    for (int y = 0; y < height; y++) {
      final int rowOffset = y * width * 4;
      for (int x = 0; x < width; x++) {
        int x1 = (x - half).clamp(0, width - 1);
        int y1 = (y - half).clamp(0, height - 1);
        int x2 = (x + half).clamp(0, width - 1);
        int y2 = (y + half).clamp(0, height - 1);

        int a = integral[y1 * (width + 1) + x1];
        int b = integral[y1 * (width + 1) + (x2 + 1)];
        int cVal = integral[(y2 + 1) * (width + 1) + x1];
        int d = integral[(y2 + 1) * (width + 1) + (x2 + 1)];

        int sum = d - b - cVal + a;
        int area = (x2 - x1 + 1) * (y2 - y1 + 1);
        int mean = sum ~/ area;
        int threshold = mean - c;

        final int currentLuminance = _pixelToLuminance(rowOffset + x * 4);
        result[y * width + x] = currentLuminance > threshold ? 255 : 0;
      }
    }
    return GrayImage(result, width: width);
  }

  /// Floyd-Steinberg dithering to produce a 1-bit binary from RGBA.
  GrayImage toImageBinary() {
    final int totalPixels = bytes.length ~/ 4;
    final height = totalPixels ~/ width;
    final List<double> buffer = .filled(totalPixels, 0.0);
    final Uint8List result = Uint8List(totalPixels);
    const double threshold = 128.0;

    for (int i = 0; i < totalPixels; i++) {
      buffer[i] = _pixelToLuminance(i * 4).toDouble();
    }

    for (int y = 0; y < height; y++) {
      final bool ltr = y % 2 == 0;
      for (int i = 0; i < width; i++) {
        final int x = ltr ? i : width - 1 - i;
        final int dir = ltr ? 1 : -1;
        final int idx = y * width + x;
        final double oldVal = buffer[idx];
        final double newVal = oldVal >= threshold ? 255.0 : 0.0;
        result[idx] = newVal == 255.0 ? 255 : 0;

        final double error = oldVal - newVal;
        // Distribute error to neighboring pixels in buffer
        if (x + dir >= 0 && x + dir < width) {
          buffer[idx + dir] += error * 7 / 16;
        }
        if (y + 1 < height) {
          final int below = idx + width;
          if (x - dir >= 0 && x - dir < width) {
            buffer[below - dir] += error * 3 / 16;
          }
          buffer[below] += error * 5 / 16;
          if (x + dir >= 0 && x + dir < width) {
            buffer[below + dir] += error * 1 / 16;
          }
        }
      }
    }

    return GrayImage(result, width: width);
  }

  /// Convert RGBA pixel to 0-255 grayscale luminance value (with Alpha blending)
  @pragma('vm:prefer-inline')
  int _pixelToLuminance(int offset) {
    final int r = bytes[offset];
    final int g = bytes[offset + 1];
    final int b = bytes[offset + 2];
    final int a = bytes[offset + 3];

    // If fully transparent or semi-transparent, blend with white background (255, 255, 255)
    int effR = r;
    int effG = g;
    int effB = b;
    if (a < 255) {
      effR = (r * a + 255 * (255 - a)) ~/ 255;
      effG = (g * a + 255 * (255 - a)) ~/ 255;
      effB = (b * a + 255 * (255 - a)) ~/ 255;
    }

    // ITU-R BT.601: (R*77 + G*150 + B*29) >> 8
    return (effR * 77 + effG * 150 + effB * 29) >> 8;
  }
}

class GrayImage extends ImageBytes {
  const GrayImage(super.bytes, {required super.width});

  /// Simple binary bitmap using a fixed global threshold (0 by default).
  /// Retained for backward compatibility.
  ConstantImage toBitMap({bool mirrored = true, bool invert = true}) {
    final result = Uint8List(bytes.length ~/ 8);
    for (var i = 0; i < bytes.length; i++) {
      final write = invert ? bytes[i] > 0 : bytes[i] == 0;
      if (write) {
        if (mirrored) {
          result[i ~/ 8] |= 1 << (i % 8);
        } else {
          result[i ~/ 8] |= 1 << (7 - i % 8);
        }
      }
    }
    return ConstantImage(result, width: width);
  }

  Future<ui.Image> toUIImage() {
    final rgba = Uint8List(bytes.length * 4);
    for (var i = 0; i < bytes.length; i++) {
      final gray = bytes[i];
      rgba[i * 4] = gray; // R
      rgba[i * 4 + 1] = gray; // G
      rgba[i * 4 + 2] = gray; // B
      rgba[i * 4 + 3] = 255; // A
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      width,
      bytes.length ~/ width,
      ui.PixelFormat.rgba8888,
      (ui.Image img) => completer.complete(img),
    );

    return completer.future;
  }

  img.Image toImage() {
    final height = bytes.length ~/ width;
    return .fromBytes(bytes: bytes.buffer, width: width, height: height, numChannels: 1);
  }
}
