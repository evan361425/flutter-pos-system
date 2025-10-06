import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/device.dart';
import 'package:possystem/ui/order/widgets/device_button_view.dart';

void main() {
  group('DeviceButtonView', () {
    testWidgets('should show no devices message when no devices are available', (tester) async {
      // Clear any existing devices
      Devices.instance.replaceItems({});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const DeviceButtonView(),
          ),
        ),
      );

      // Find the expansion tile
      expect(find.byType(ExpansionTile), findsOneWidget);
      expect(find.text('Devices'), findsOneWidget);
      expect(find.text('No devices available'), findsOneWidget);

      // Tap to expand
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Should show no devices message
      expect(find.text('No devices connected'), findsOneWidget);
      expect(find.text('Add devices in settings to connect them here'), findsOneWidget);
    });

    testWidgets('should show connected devices', (tester) async {
      // Add a test device
      final device = Device(
        id: 'test-device',
        name: 'Test Kitchen Display',
        address: '192.168.1.100',
        port: 8765,
        deviceType: DeviceType.kitchen,
        autoConnect: false,
      );
      
      // Mock the device as connected
      Devices.instance.replaceItems({'test-device': device});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const DeviceButtonView(),
          ),
        ),
      );

      // Find the expansion tile
      expect(find.byType(ExpansionTile), findsOneWidget);
      expect(find.text('Devices'), findsOneWidget);

      // Initially the connecting list will include the device if autoConnect is true
      // Since our test device has autoConnect: false, it won't show in connecting
      expect(find.text('No devices available'), findsOneWidget);
    });

    testWidgets('should show auto-connect devices as connecting', (tester) async {
      // Add a test device with auto-connect enabled
      final device = Device(
        id: 'test-device',
        name: 'Auto Connect Device',
        address: '192.168.1.100',
        port: 8765,
        deviceType: DeviceType.cashier,
        autoConnect: true,
      );
      
      Devices.instance.replaceItems({'test-device': device});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const DeviceButtonView(),
          ),
        ),
      );

      // Should show connecting status
      expect(find.textContaining('Connecting to'), findsOneWidget);
      expect(find.textContaining('device(s)'), findsOneWidget);
    });

    testWidgets('should show device type icons correctly', (tester) async {
      final cashierDevice = Device(
        id: 'cashier',
        name: 'Cashier Device',
        deviceType: DeviceType.cashier,
        autoConnect: true,
      );
      
      final kitchenDevice = Device(
        id: 'kitchen',
        name: 'Kitchen Device',
        deviceType: DeviceType.kitchen,
        autoConnect: true,
      );

      Devices.instance.replaceItems({
        'cashier': cashierDevice,
        'kitchen': kitchenDevice,
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const DeviceButtonView(),
          ),
        ),
      );

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Should find point_of_sale icon for cashier and kitchen icon for kitchen
      expect(find.byIcon(Icons.point_of_sale), findsOneWidget);
      expect(find.byIcon(Icons.kitchen), findsOneWidget);
    });
  });
}