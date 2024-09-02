import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void deviceAs(Device device, WidgetTester tester) {
  tester.view.physicalSize = Size(device.width, device.height);
  tester.view.devicePixelRatio = 1.0;

  // resets the screen to its original size after the test end
  addTearDown(tester.view.resetPhysicalSize);
}

enum Device {
  mobile(800, 1500),
  landscape(1024, 768),
  desktop(1440, 900),
  ;

  final double width;
  final double height;

  const Device(this.width, this.height);
}
