import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/printer/printer_page.dart';

import '../../mocks/mock_bluetooth.dart';
import '../../mocks/mock_bluetooth.mocks.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Printer Page', () {
    Widget buildApp() {
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: PrinterPage()),
          ),
          ...Routes.getDesiredRoute(0).routes,
        ]),
      );
    }

    testWidgets('Create printer', (tester) async {
      final notSupport = MockBluetoothDevice();
      final existAndConnected = MockBluetoothDevice();
      final device = MockBluetoothDevice();
      final controller = StreamController<List<BluetoothDevice>>();
      when(blue.startScan()).thenAnswer((_) => controller.stream);
      when(blue.stopScan()).thenAnswer((_) => Future.value());
      when(storage.set(any, any)).thenAnswer((_) => Future.value());

      void mockDevice(MockBluetoothDevice d, String name, String address, bool connected) {
        when(d.name).thenReturn(name);
        when(d.address).thenReturn(address);
        when(d.connected).thenReturn(connected);
      }

      mockDevice(notSupport, 'unknown', 'address1', false);
      mockDevice(existAndConnected, 'exist', 'address2', true);
      mockDevice(device, 'MX11', 'address3', false);

      await tester.pumpWidget(buildApp());
      Printers.instance.replaceItems({'exist': Printer(name: 'exist', address: 'address2')});

      await tester.tap(find.text(S.printerTitleCreate));
      await tester.pump(const Duration(milliseconds: 10));

      expect(find.text(S.printerScanIng), findsOneWidget);

      controller.add([notSupport, existAndConnected, device]);
      await tester.pump();

      // tap not support
      await tester.tap(find.text('unknown'));
      await tester.pump(const Duration(milliseconds: 10));

      expect(find.text(S.printerErrorNotSupportTitle), findsOneWidget);

      // exist has no add icon
      expect(find.byIcon(Icons.add), findsNWidgets(2));

      // show not found dialog
      await tester.tap(find.text(S.printerScanNotFound));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.tapAt(const Offset(10, 10));
      await tester.pump(const Duration(milliseconds: 10));

      // show not select
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pump(const Duration(milliseconds: 30));
      expect(find.text(S.printerErrorNotSelect), findsOneWidget);

      // tap device
      await tester.tap(find.text('MX11'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.printerAutoConnLabel));
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('printer.format')), findsOneWidget);
      expect(find.text('MX11'), findsOneWidget);
      verify(storage.set(
        any,
        argThat(predicate((v) {
          if (!(v is Map<String, Object?> && v.keys.length == 1 && v.keys.first.startsWith('printer.'))) return false;

          final map = v.values.first as Map<String, Object?>;
          return map['name'] == 'MX11' &&
              map['address'] == 'address3' &&
              map['autoConnect'] == true &&
              map['provider'] == 1 &&
              map.keys.length == 4;
        })),
      )).called(1);
    });

    testWidgets("Edit printer", (tester) async {
      final printer = MockPrinter();
      when(storage.set(any, any)).thenAnswer((_) => Future.value());
      when(printer.connected).thenReturn(false);
      Printers.instance.replaceItems({'id': Printer(id: 'id', name: 'name1', address: 'address')..p = printer});

      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('name1'));
      await tester.pumpAndSettle();

      when(printer.connect()).thenAnswer((_) => Future.value(true));
      await tester.tap(find.text(S.printerBtnConnect).last);

      // connect in modal, should update page's status
    });

    testWidgets("Delete printer", (tester) async {});
  });

  setUpAll(() {
    initializeBlue();
    initializeStorage();
    initializeTranslator();
  });

  setUp(() {
    reset(blue);
    Printers();
  });
}
