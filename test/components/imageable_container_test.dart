import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/imageable_container.dart';

import '../test_helpers/breakpoint_mocker.dart';

void main() {
  group('Imageable Container', () {
    testWidgets('should render and hit the assertion', (tester) async {
      deviceAs(.mobile, tester);

      final controller = ImageableManger.instance.create();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SizedBox(
              width: 800, // 772, which has floating error in 99, 105, 111, 117, 123, 198, ...
              child: ImageableContainer(
                controller: controller,
                style: const TextStyle(color: Colors.black),
                children: const [Text('Hello World')],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final image = await tester.runAsync(() => controller.toImage(widths: [128]));
      expect(image, isNotNull);

      await tester.runAsync(() => controller.toImage(widths: [99]));
      expect(tester.takeException(), isAssertionError);
    });
  });
}
