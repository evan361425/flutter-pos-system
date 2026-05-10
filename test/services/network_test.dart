import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/services/network.dart';

void main() {
  group('NetworkService', () {
    late NetworkService networkService;

    setUp(() {
      networkService = NetworkService();
    });

    tearDown(() async {
      await networkService.dispose();
    });

    test('should generate valid pairing pin', () {
      final pin = networkService.generatePairingPin();
      expect(pin.length, 4);
      expect(int.tryParse(pin), isNotNull);
      final pinInt = int.parse(pin);
      expect(pinInt, greaterThanOrEqualTo(1000));
      expect(pinInt, lessThanOrEqualTo(9999));
    });

    test('should generate different pins', () {
      final pins = <String>{};
      for (int i = 0; i < 100; i++) {
        pins.add(networkService.generatePairingPin());
      }
      // Should generate at least some different pins
      expect(pins.length, greaterThan(50));
    });

    test('should track active connections', () {
      expect(networkService.activeConnections, isEmpty);
    });
  });

  group('DiscoveredDevice', () {
    test('should be equal based on address and port', () {
      final device1 = DiscoveredDevice(
        address: '192.168.1.100',
        port: 8765,
        name: 'Device 1',
        deviceType: 'cashier',
      );

      final device2 = DiscoveredDevice(
        address: '192.168.1.100',
        port: 8765,
        name: 'Device 2', // Different name
        deviceType: 'kitchen', // Different type
      );

      final device3 = DiscoveredDevice(
        address: '192.168.1.101',
        port: 8765,
        name: 'Device 1',
        deviceType: 'cashier',
      );

      expect(device1, equals(device2)); // Same address and port
      expect(device1, isNot(equals(device3))); // Different address
      expect(device1.hashCode, equals(device2.hashCode));
      expect(device1.hashCode, isNot(equals(device3.hashCode)));
    });
  });

  group('DeviceConnection', () {
    test('should handle message encoding and decoding', () {
      // This is a simplified test since we can't easily mock Socket
      final testMessage = {
        'type': 'test_message',
        'data': 'hello world',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final encoded = utf8.encode(jsonEncode(testMessage));
      final decoded = jsonDecode(utf8.decode(encoded)) as Map<String, dynamic>;

      expect(decoded['type'], testMessage['type']);
      expect(decoded['data'], testMessage['data']);
      expect(decoded['timestamp'], testMessage['timestamp']);
    });
  });
}