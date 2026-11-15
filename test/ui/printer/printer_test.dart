import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/ui/printer/widgets/printer_receipt_view.dart';

void main() {
  testWidgets('Check printer rendered binary image is correct', (WidgetTester tester) async {
    final fontBytes = File('scripts/Tra-Chi.ttf').readAsBytesSync();
    final loader = FontLoader('Tra-Chi')..addFont(Future.value(ByteData.sublistView(fontBytes)));
    await loader.load();
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = ImageableManger.instance.create();
    ReceiptTemplates.reset();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Tra-Chi'),
        home: Scaffold(
          body: Padding(
            padding: const .only(left: 12.0, top: 8.0, right: 12.0, bottom: 12.0),
            child: DefaultTextStyle(
              style: const TextStyle(fontFamily: 'Tra-Chi'),
              child: PrinterReceiptView(
                controller: controller,
                order: OrderObject.example(createdAt: DateTime(2026, 11, 15, 11, 37, 43)),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final images = await tester.runAsync(() => controller.toImage(widths: [384]));
    expect(images, isNotNull);

    final bytes = images?.map((e) => e.toGrayScale().toBitMap(mirrored: false)).first.bytes;
    expect(images, isNotNull);

    const width = 384;
    const bytesPerRow = width ~/ 8;
    final height = bytes!.length ~/ bytesPerRow;
    final image = img.Image(width: width, height: height);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final byte = bytes[y * bytesPerRow + (x >> 3)];
        final bit = (byte >> (7 - (x & 7))) & 1;
        final v = bit > 0 ? 255 : 0;
        image.setPixelRgb(x, y, v, v, v);
      }
    }

    final golden = File('test/goldens/receipt.png');
    final png = img.encodePng(image);

    if (autoUpdateGoldenFiles) {
      golden.writeAsBytesSync(png);
    } else {
      expect(png, orderedEquals(golden.readAsBytesSync()));
    }
  });
}
