import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/style/snackbar.dart';

void main() {
  group('Widget Snackbar', () {
    testWidgets('should show info after pressing button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
                onPressed: () {
                  showMoreInfoSnackBar(context, 'message', const Text('info'),
                      label: 'test');
                },
                child: const Text('btn'));
          }),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('btn'));
      await tester.pump();

      expect(find.text('message'), findsOneWidget);

      await tester.tap(find.text('test'));
      await tester.pumpAndSettle();

      expect(find.text('info'), findsOneWidget);
    });
  });
}
