import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/device.dart';
import 'package:possystem/models/objects/device_object.dart';
import 'package:possystem/services/network.dart';

void main() {
  group('Device', () {
    late Device device;

    setUp(() {
      device = Device(
        id: 'test_device',
        name: 'Test Device',
        address: '192.168.1.100',
        port: 8765,
        deviceType: DeviceType.kitchen,
        autoConnect: true,
      );
    });

    test('should create device from object', () {
      final obj = DeviceObject(
        id: 'test',
        name: 'Kitchen Display',
        address: '192.168.1.50',
        port: 8765,
        autoConnect: false,
        deviceType: 'kitchen',
        isPaired: true,
      );

      final device = Device.fromObject(obj);

      expect(device.id, 'test');
      expect(device.name, 'Kitchen Display');
      expect(device.address, '192.168.1.50');
      expect(device.port, 8765);
      expect(device.autoConnect, false);
      expect(device.deviceType, DeviceType.kitchen);
      expect(device.isPaired, true);
    });

    test('should convert device to object', () {
      device.isPaired = true;
      final obj = device.toObject();

      expect(obj.id, 'test_device');
      expect(obj.name, 'Test Device');
      expect(obj.address, '192.168.1.100');
      expect(obj.port, 8765);
      expect(obj.autoConnect, true);
      expect(obj.deviceType, 'kitchen');
      expect(obj.isPaired, true);
    });

    test('should be comparable', () {
      final device1 = Device(name: 'A Device');
      final device2 = Device(name: 'B Device');

      expect(device1.compareTo(device2), lessThan(0));
      expect(device2.compareTo(device1), greaterThan(0));
      expect(device1.compareTo(device1), equals(0));
    });

    test('should handle device type conversion', () {
      expect(DeviceType.fromString('cashier'), DeviceType.cashier);
      expect(DeviceType.fromString('kitchen'), DeviceType.kitchen);
      expect(DeviceType.fromString('display'), DeviceType.display);
      expect(DeviceType.fromString('unknown_type'), DeviceType.unknown);
    });
  });

  group('DeviceObject', () {
    test('should build from map', () {
      final data = {
        'id': 'test',
        'name': 'Test Device',
        'address': '192.168.1.100',
        'port': 8765,
        'autoConnect': true,
        'deviceType': 'cashier',
        'isPaired': false,
      };

      final obj = DeviceObject.build(data);

      expect(obj.id, 'test');
      expect(obj.name, 'Test Device');
      expect(obj.address, '192.168.1.100');
      expect(obj.port, 8765);
      expect(obj.autoConnect, true);
      expect(obj.deviceType, 'cashier');
      expect(obj.isPaired, false);
    });

    test('should convert to map', () {
      final obj = DeviceObject(
        id: 'test',
        name: 'Test Device',
        address: '192.168.1.100',
        port: 8765,
        autoConnect: true,
        deviceType: 'kitchen',
        isPaired: true,
      );

      final map = obj.toMap();

      expect(map['id'], 'test');
      expect(map['name'], 'Test Device');
      expect(map['address'], '192.168.1.100');
      expect(map['port'], 8765);
      expect(map['autoConnect'], true);
      expect(map['deviceType'], 'kitchen');
      expect(map['isPaired'], true);
    });

    test('should calculate diff correctly', () {
      final original = DeviceObject(
        name: 'Original',
        address: '192.168.1.1',
        port: 8765,
        autoConnect: false,
        deviceType: 'cashier',
        isPaired: false,
      );

      final updated = DeviceObject(
        name: 'Updated',
        address: '192.168.1.1',
        port: 8080,
        autoConnect: true,
        deviceType: 'kitchen',
        isPaired: true,
      );

      final diff = original.diff(updated);

      expect(diff['name'], 'Updated');
      expect(diff['port'], 8080);
      expect(diff['autoConnect'], true);
      expect(diff['deviceType'], 'kitchen');
      expect(diff['isPaired'], true);
      // Address should not be in diff since it's the same
      expect(diff.containsKey('address'), false);
    });
  });

  group('Devices Repository', () {
    test('should initialize correctly', () {
      final devices = Devices();
      expect(devices.items, isEmpty);
      expect(devices.hasConnected, false);
    });

    test('should check address existence', () {
      final devices = Devices();
      final device = Device(address: '192.168.1.100');
      devices.replaceItems({'test': device});

      expect(devices.hasAddress('192.168.1.100'), true);
      expect(devices.hasAddress('192.168.1.200'), false);
    });

    test('should build item from data', () {
      final devices = Devices();
      final data = {
        'name': 'Test Device',
        'address': '192.168.1.100',
        'port': 8765,
        'autoConnect': true,
        'deviceType': 'kitchen',
        'isPaired': false,
      };

      final device = devices.buildItem('test_id', data);

      expect(device.id, 'test_id');
      expect(device.name, 'Test Device');
      expect(device.address, '192.168.1.100');
      expect(device.deviceType, DeviceType.kitchen);
    });
  });
}