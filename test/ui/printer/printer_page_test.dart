import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/bluetooth.dart';
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

      // show not found more dialog
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

      // scan error
      await controller.close();
      await tester.pump();

      // tap device
      await tester.tap(find.text('MX11'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.printerAutoConnLabel));
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('printer.settings')), findsOneWidget);
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

    testWidgets("Edit printer with connection handling", (tester) async {
      final p = MockPrinter();
      bool connected = false;
      when(p.connected).thenAnswer((_) => connected);

      final printer = Printer(id: 'id', name: 'name1', address: 'address')..p = p;
      Printers.instance.replaceItems({'id': printer});

      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('name1'));
      await tester.pumpAndSettle();

      when(p.connect()).thenAnswer((_) => Future.value(false));
      await tester.tap(find.text(S.printerBtnConnect).last);
      await tester.pumpAndSettle();

      expect(find.text(S.printerErrorNotSupportTitle), findsOneWidget);

      when(p.connect()).thenAnswer((_) {
        connected = true;
        printer.notifyItem();
        return Future.value(true);
      });
      when(p.disconnect()).thenAnswer((_) {
        connected = false;
        printer.notifyItem();
        return Future.value();
      });

      await tester.tap(find.text(S.printerBtnConnect).last);
      await tester.pumpAndSettle();
      expect(find.text(S.printerStatusConnecting), findsWidgets);

      await tester.tap(find.text(S.printerStatusConnecting).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.printerBtnDisconnect).last);
      await tester.pumpAndSettle();
      expect(find.text(S.printerStatusStandby), findsWidgets);

      await tester.tap(find.text(S.printerBtnConnect).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.printerStatusConnecting).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.printerBtnRetry).last);
      await tester.pumpAndSettle();
      expect(find.text(S.printerStatusConnecting), findsWidgets);

      await tester.enterText(find.byKey(const Key('printer.name')), 'evan');
      await tester.tap(find.text(S.printerAutoConnLabel));
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      // connect in modal, should update page's status
      expect(find.text(S.printerStatusConnecting), findsWidgets);
      expect(find.text('evan'), findsWidgets);

      verify(storage.set(any, {'printer.id.name': 'evan', 'printer.id.autoConnect': true})).called(1);
    });

    testWidgets("Delete printer", (tester) async {
      final p = MockPrinter();
      when(p.connected).thenReturn(false);
      Printers.instance.replaceItems({'id': Printer(id: 'id', name: 'name1', address: 'address')..p = p});

      await tester.pumpWidget(buildApp());

      await tester.tap(find.byIcon(KIcons.entryMore));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      verify(storage.set(any, {'printer.id': null})).called(1);
      expect(find.text(S.printerMetaHelper), findsOneWidget);
    });

    testWidgets("Test print", (tester) async {
      final printer = Printer(id: 'id', name: 'name', address: 'address');
      final controller = StreamController<double>();
      final p = MockPrinter();
      when(p.connected).thenReturn(true);
      when(p.draw(any, density: anyNamed('density'))).thenAnswer((_) => controller.stream);
      prepareImageable();

      Printers.instance.replaceItems({'id': printer..p = p});

      await tester.pumpWidget(buildApp());

      await tester.tap(find.text(S.printerBtnTestPrint));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.printerBtnPrint));
      await tester.pumpAndSettle();

      controller.add(0.5);
      await tester.pumpAndSettle();

      // tap should not work when printing
      await tester.tapAt(tester.getCenter(find.text(S.printerBtnPrint)));

      controller.add(0.8);
      await tester.pump();
      controller.add(1);
      await tester.pumpAndSettle();
      await controller.close();
      await tester.pumpAndSettle();

      verify(p.draw(any, density: anyNamed('density'))).called(1);
      expect(find.text(S.printerStatusPrinted), findsOneWidget);
    });

    testWidgets("Settings", (tester) async {
      Printers.instance.replaceItems({'id': Printer(id: 'id', name: 'name', address: 'address')});

      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('printer.settings')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.printerSettingsPaddingLabel));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('printer.settings')), findsOneWidget);
      verify(storage.set(any, {
        'setting': {'density': 1}
      })).called(1);
      expect(Printers.instance.density, PrinterDensity.tight);
    });
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

  tearDown(resetImageable);
}
