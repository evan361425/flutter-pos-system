import 'dart:async';

import 'package:packages/bluetooth.dart' as bt;

typedef BluetoothSignal = bt.BluetoothSignal;
typedef PrinterStatus = bt.PrinterStatus;
typedef PrinterDensity = bt.PrinterDensity;
typedef BluetoothException = bt.BluetoothException;
typedef BluetoothExceptionCode = bt.BluetoothExceptionCode;
typedef BluetoothExceptionFrom = bt.BluetoothExceptionFrom;
typedef BluetoothOffException = bt.BluetoothOffException;

class Bluetooth {
  static Bluetooth instance = Bluetooth();

  final bt.Bluetooth blue;

  Bluetooth({bt.Bluetooth? blue}) : blue = blue ?? bt.Bluetooth.i;

  /// Timeout in 3 minutes
  Stream<List<bt.BluetoothDevice>> startScan() => blue.startScan();

  Future<void> stopScan() => blue.stopScan();
}
