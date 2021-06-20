import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';

import '../mocks/mock_widgets.dart';

void main() {
  Widget createWidget(List<Widget> actions) {
    return MediaQuery(
      data: MediaQueryData(padding: EdgeInsets.all(20.0)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: BottomSheetActions(actions: actions),
      ),
    );
  }

  testWidgets('should set up actions', (WidgetTester tester) async {
    const actions = <Widget>[Text('hi')];
    await tester.pumpWidget(createWidget(actions));

    expect(find.text('hi'), findsOneWidget);
  });

  testWidgets('should cancelable', (WidgetTester tester) async {
    await tester.pumpWidget(bindWithNavigator(createWidget([])));

    await tester.tap(find.byIcon(Icons.cancel_sharp));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cancel_sharp), findsNothing);
  });

  test('should failed if missing actions and builder', () {
    expect(() => showCircularBottomSheet(MockBuildContext()),
        throwsAssertionError);
  });
}
