import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/services/bluetooth.dart';
import 'package:possystem/translator.dart';

import '../test_helpers/translator.dart';

void main() {
  group('Widget Snackbar', () {
    testWidgets('should show info after pressing button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
                onPressed: () {
                  showMoreInfoSnackBar(
                    'message',
                    const Text('info'),
                    context: context,
                  );
                },
                child: const Text('btn'));
          }),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('btn'));
      await tester.pumpAndSettle();

      expect(find.text('message'), findsOneWidget);

      await tester.tap(find.text(S.actMoreInfo));
      await tester.pumpAndSettle();

      expect(find.text('info'), findsOneWidget);
    });

    test('prettier error', () async {
      Future<void> buildError(int index) {
        return Future.error(BluetoothException(BluetoothExceptionFrom.android, 'test', index, 'message'));
      }

      await showSnackbarWhenFutureError(Future.error(BluetoothOffException()), 'test');
      await showSnackbarWhenFutureError(
          Future.error(PlatformException(code: 'connect', message: 'bluetooth must turning on')), 'test');
      await showSnackbarWhenFutureError(buildError(BluetoothExceptionCode.timeout.index), 'test');
      await showSnackbarWhenFutureError(buildError(BluetoothExceptionCode.deviceIsDisconnected.index), 'test');
      await showSnackbarWhenFutureError(buildError(BluetoothExceptionCode.serviceNotFound.index), 'test');
      await showSnackbarWhenFutureError(buildError(BluetoothExceptionCode.adapterIsOff.index), 'test');
      await showSnackbarWhenFutureError(buildError(BluetoothExceptionCode.androidOnly.index), 'test');
      await showSnackbarWhenStreamError(Stream.fromFuture(buildError(BluetoothExceptionCode.androidOnly.index)), 'test',
              callback: () {})
          .drain();
    });
  });

  setUpAll(() {
    initializeTranslator();
  });
}
