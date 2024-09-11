import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void deviceAs(Device device, WidgetTester tester) {
  tester.view.physicalSize = Size(device.width, device.height);

  // resets the screen to its original size after the test end
  addTearDown(tester.view.resetPhysicalSize);
}

enum Device {
  compact(500, 1200),
  mobile(800, 1500),
  landscape(1024, 768),
  desktop(1800, 900);

  final double width;
  final double height;

  const Device(double width, double height)
      // devicePixelRatio = 3.0
      : width = width * 3.0,
        height = height * 3.0;
}
