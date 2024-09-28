import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/imageable_container.dart';

import '../test_helpers/breakpoint_mocker.dart';

void main() {
  group('Imageable Container', () {
    testWidgets('should render correctly', (tester) async {
      deviceAs(Device.mobile, tester);

      final controller = ImageableController(key: GlobalKey());

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: ImageableContainer(
            controller: controller,
            children: const [
              Text('Hello World'),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final image = await tester.runAsync(() => controller.toImage(widths: [128]));
      expect(image, isNotNull);

      const width = 128 ~/ 8;
      final data = image!.first.toGrayScale().toBitMap(invert: false, mirrored: false).bytes;
      var line = '';
      for (var i = 0; i < data.length ~/ width; i++) {
        for (var j = 0; j < width; j++) {
          line += data[i * width + j].toRadixString(2).padLeft(8, '0');
        }
        line += '\n';
      }

      expect(
        line,
        '11111111111111100111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\n'
        '11111111111111100111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\n'
        '11111111111111100111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\n',
      );
    });
  });
}
