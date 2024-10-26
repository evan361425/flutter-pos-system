import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/style/snackbar.dart';
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
  });

  setUpAll(() {
    initializeTranslator();
  });
}
