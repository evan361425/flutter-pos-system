import 'package:bluetooth/bluetooth.dart' as bt;
import 'package:mockito/annotations.dart';
import 'package:possystem/services/bluetooth.dart';

import 'mock_bluetooth.mocks.dart';

final blue = MockBluetooth();

@GenerateMocks([
  bt.Bluetooth,
  bt.Printer,
  bt.BluetoothDevice,
])
void initializeBlue() {
  Bluetooth.instance = Bluetooth(blue: blue);
}
