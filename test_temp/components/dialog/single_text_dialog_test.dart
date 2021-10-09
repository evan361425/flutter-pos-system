import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/helpers/validator.dart';

import '../../mocks/mock_widgets.dart';

void main() {
  Widget createDialog(Widget dialog) {
    return Material(child: MaterialApp(home: dialog));
  }

  testWidgets('should validate before submit', (WidgetTester tester) async {
    final dialog = createDialog(SingleTextDialog(
      initialValue: '50',
      validator: Validator.positiveInt('hi', maximum: 10),
    ));

    await tester.pumpWidget(bindWithNavigator(dialog));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
