import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';

import '../test_helpers/translator.dart';

void main() {
  group('Widget BottomSheetActions', () {
    testWidgets('should cancelable', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: _ExampleWidget()));

      await tester.tap(find.text('hi'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.cancel_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cancel_outlined), findsNothing);
    });

    setUpAll(() {
      initializeTranslator();
    });
  });
}

class _ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showCircularBottomSheet(context, actions: []),
      child: const Text('hi'),
    );
  }
}
