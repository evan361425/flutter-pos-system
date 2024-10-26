import 'dart:async';

import 'package:bluetooth/bluetooth.dart' as bt;
import 'package:possystem/helpers/logger.dart';

typedef BluetoothSignal = bt.BluetoothSignal;
typedef PrinterStatus = bt.PrinterStatus;
typedef PrinterDensity = bt.PrinterDensity;
typedef BluetoothException = bt.BluetoothException;
typedef BluetoothExceptionCode = bt.BluetoothExceptionCode;
typedef BluetoothOffException = bt.BluetoothOffException;

class Bluetooth {
  static Bluetooth instance = Bluetooth();

  final bt.Bluetooth blue;

  Bluetooth({bt.Bluetooth? blue}) : blue = blue ?? bt.Bluetooth.i;

  /// Timeout in 3 minutes
  Stream<List<bt.BluetoothDevice>> startScan() {
    Log.ger('start scanning', 'bt_scan');
    return blue.startScan();
  }

  Future<bt.BluetoothDevice?> connect(String address) {
    Log.ger('connect to: $address', 'bt_connect');
    return blue.connect(address);
  }

  Future<void> stopScan() {
    Log.ger('stop scanning', 'bt_scan');
    return blue.stopScan();
  }
}
