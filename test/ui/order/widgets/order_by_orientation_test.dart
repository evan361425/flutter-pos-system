import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/ui/order/widgets/order_by_orientation.dart';

void main() {
  testWidgets('should build success in different mode', (tester) async {
    const WIDTH = 1300.0;
    const HEIGHT = 700.0;

    tester.binding.window.physicalSizeTestValue = Size(WIDTH, HEIGHT);

    // resets the screen to its orinal size after the test end
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(MaterialApp(
      home: OrderByOrientation(
          row1: Text('abc'),
          row2: Text('def'),
          row3: Text('ghi'),
          row4: Text('jkl')),
    ));

    tester.binding.window.physicalSizeTestValue = Size(HEIGHT, WIDTH);
    await tester.pumpAndSettle();
  });
}
