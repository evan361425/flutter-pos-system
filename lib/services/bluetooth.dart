import 'dart:typed_data';

class Bluetooth {
  static Bluetooth instance = Bluetooth();

  Stream<BluetoothDevice> scan() {
    return const Stream.empty();
  }

  Future<String?> connect(BluetoothDevice device) async {
    return null;
  }

  Future<bool> write(Uint8List data) async {
    return true;
  }
}

class BluetoothDevice {
  final String? name;
  final String address;

  const BluetoothDevice({required this.name, required this.address});
}
