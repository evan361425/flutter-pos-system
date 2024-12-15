import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/app.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/services/bluetooth.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/widgets/printer_button_view.dart';

import '../../mocks/mock_bluetooth.dart';
import '../../mocks/mock_bluetooth.mocks.dart';
import '../../mocks/mock_cache.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Order Printer Button', () {
    Widget buildWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: PrinterButtonView(),
        ),
      );
    }

    testWidgets('connecting two printer, success and failed', (WidgetTester tester) async {
      final printer1 = Printer(id: '1', name: '1', address: '1', autoConnect: true);
      final printer2 = Printer(id: '2', name: '2', address: '2', autoConnect: true);
      final p1 = MockPrinter();
      final p2 = MockPrinter();
      final device = MockBluetoothDevice();
      final statusController = StreamController<PrinterStatus>()..add(PrinterStatus.good);
      Printers.instance.replaceItems({'1': printer1..p = p1, '2': printer2..p = p2});

      bool p1Connected = false;
      when(p1.device).thenReturn(device);
      when(p1.connected).thenAnswer((_) => p1Connected);
      when(p2.connected).thenReturn(false);
      when(p1.connect()).thenAnswer((_) async {
        p1Connected = true;
        printer1.notifyItem();
        return true;
      });
      when(p2.connect()).thenAnswer((_) async => false);
      when(p1.statusStream).thenAnswer((_) => statusController.stream);
      when(device.createSignalStream()).thenAnswer((_) => Stream.value(BluetoothSignal.weak));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.print_outlined), findsOneWidget);

      statusController.add(PrinterStatus.paperNotFound);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      statusController.add(PrinterStatus.printing);
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disconnect and connect back by dialog', (WidgetTester tester) async {
      final printer = Printer(id: '1', name: 'name', address: '1', autoConnect: true);
      final p = MockPrinter();
      final device = MockBluetoothDevice();
      Printers.instance.replaceItems({'1': printer..p = p});

      bool connected = true;
      when(p.device).thenReturn(device);
      when(p.connected).thenAnswer((_) => connected);
      when(p.connect()).thenAnswer((_) async {
        connected = true;
        printer.notifyItem();
        return true;
      });
      when(p.disconnect()).thenAnswer((_) async {
        connected = false;
        printer.notifyItem();
      });
      when(p.statusStream).thenAnswer((_) => Stream.value(PrinterStatus.good));
      when(device.createSignalStream()).thenAnswer((_) => Stream.value(BluetoothSignal.normal));

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byIcon(Icons.print_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('name'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.printerBtnDisconnect));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.print_disabled_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('name'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.printerBtnConnect));
      await tester.pumpAndSettle();
    });
  });

  group('Order with printer', () {
    Widget buildApp() {
      return MaterialApp(
        scaffoldMessengerKey: App.scaffoldMessengerKey,
        home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
              onPressed: () async {
                final receipts = await Printers.instance.generateReceipts(
                  context: context,
                  order: OrderObject(createdAt: DateTime.now()),
                );
                if (receipts != null) {
                  Printers.instance.printReceipts(receipts);
                }
              },
              child: const Text('tap me'),
            );
          }),
        ),
      );
    }

    testWidgets('no connected printers', (tester) async {
      final ctr = prepareImageable(null);
      Printers.instance.replaceItems({'1': Printer(id: '1', name: '1')});

      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('tap me'));
      await tester.pumpAndSettle();

      verifyNever(ctr.toImage(widths: anyNamed('widths')));
    });

    testWidgets('build null image', (tester) async {
      prepareImageable(Future.value(null));

      final p = MockPrinter();
      final m = MockPrinterManufactory();
      when(p.connected).thenReturn(true);
      when(p.manufactory).thenReturn(m);
      when(m.widthBits).thenReturn(1);
      Printers.instance.replaceItems({'1': Printer(id: '1', name: '1')..p = p});

      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('tap me'));
      await tester.pumpAndSettle();

      expect(find.text(S.orderPrinterErrorCreateReceipt), findsOneWidget);
    });

    testWidgets('build failed image', (tester) async {
      final ctr = prepareImageable();
      when(ctr.toImage(widths: argThat(equals([384]), named: 'widths'))).thenAnswer((_) => Future.error('test error'));

      final p = MockPrinter();
      final m = MockPrinterManufactory();
      when(p.connected).thenReturn(true);
      when(p.manufactory).thenReturn(m);
      when(m.widthBits).thenReturn(384);
      Printers.instance.replaceItems({'1': Printer(id: '1', name: '1')..p = p});

      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('tap me'));
      await tester.pumpAndSettle();

      expect(find.text('test error'), findsOneWidget);
    });

    testWidgets('one success, one failed', (tester) async {
      prepareImageable(Future.value([
        ConvertibleImage(Uint8List.fromList(List.filled(32, 1)), width: 8),
        ConvertibleImage(Uint8List(64), width: 16),
      ]));

      final p1 = MockPrinter();
      final p2 = MockPrinter();
      final m1 = MockPrinterManufactory();
      final m2 = MockPrinterManufactory();
      when(p1.connected).thenReturn(true);
      when(p1.manufactory).thenReturn(m1);
      when(p2.connected).thenReturn(true);
      when(p2.manufactory).thenReturn(m2);
      when(m1.widthBits).thenReturn(8);
      when(m2.widthBits).thenReturn(16);
      when(p1.draw(any, density: anyNamed('density'))).thenAnswer((_) => Stream.value(1.0));
      when(p2.draw(any, density: anyNamed('density'))).thenAnswer((_) => Stream.error('test error'));
      Printers.instance.replaceItems({
        '1': Printer(id: '1', name: '1')..p = p1,
        '2': Printer(id: '2', name: '2')..p = p2,
      });

      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('tap me'));
      await tester.pumpAndSettle();

      expect(find.text('2: test error'), findsOneWidget);
      verify(p1.draw(Uint8List.fromList([255]))).called(1);
      verify(p2.draw(Uint8List.fromList([0, 0]))).called(1);
    });

    tearDown(resetImageable);
  });

  setUpAll(() {
    Printers();
    initializeCache();
    initializeTranslator();

    // disable tutorial
    when(cache.get(any)).thenReturn(true);
  });
}
