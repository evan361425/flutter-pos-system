import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:packages/bluetooth.dart' as bt;
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/services/bluetooth.dart';

import 'mock_bluetooth.mocks.dart';

final blue = MockBluetooth();

@GenerateMocks([
  bt.Bluetooth,
  bt.Printer,
  bt.BluetoothDevice,
  bt.PrinterManufactory,
  ImageableManger,
  ImageableController,
])
void initializeBlue() {
  Bluetooth.instance = Bluetooth(blue: blue);
}

MockImageableController prepareImageable([Future<List<ConvertibleImage>?>? result]) {
  final manger = ImageableManger.instance = MockImageableManger();
  final controller = MockImageableController();
  when(manger.create()).thenReturn(controller);
  when(controller.key).thenReturn(GlobalKey());
  when(controller.toImage(widths: anyNamed('widths')))
      .thenAnswer((_) => result ?? Future.value([ConvertibleImage(Uint8List(4), width: 1)]));

  return controller;
}

void resetImageable() {
  ImageableManger.instance = ImageableManger();
}
