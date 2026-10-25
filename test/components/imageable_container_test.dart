import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/imageable_container.dart';

import '../test_helpers/breakpoint_mocker.dart';

void main() {
  group('Imageable Container', () {
    testWidgets('should render correctly', (tester) async {
      deviceAs(.mobile, tester);

      final controller = ImageableManger.instance.create();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ImageableContainer(
              controller: controller,
              style: const TextStyle(color: Colors.black),
              children: const [Text('Hello World')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final image = await tester.runAsync(() => controller.toImage(widths: [128]));
      expect(image, isNotNull);

      const width = 128 ~/ 8;
      final data = image!.first.toGrayScale().toBitMap(invert: false, mirrored: false).bytes;
      final lines = <String>[];
      for (var i = 0; i < data.length ~/ width; i++) {
        var line = '';
        for (var j = 0; j < width; j++) {
          line += data[i * width + j].toRadixString(2).padLeft(8, '0');
        }
        lines.add(line);
      }

      expect(
        lines[0],
        equals(
          '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
        ),
      );
      expect(
        lines[1],
        equals(
          '11010111101000110101011010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
        ),
      );
      expect(
        lines[2],
        equals(
          '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
        ),
      );
    });
  });
}
