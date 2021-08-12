import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/components/style/circular_loading.dart';

void main() {
  testWidgets('should show spinner', (WidgetTester tester) async {
    final widget = MaterialApp(
      home: SearchScaffold<String>(
        text: 'abc',
        handleChanged: (text) =>
            Future.delayed(Duration(milliseconds: 11)).then((_) => ['b']),
        itemBuilder: (_, i) => Text(i),
        emptyBuilder: (_, text) => Text(text),
        initialData: ['a'],
      ),
    );
    await tester.pumpWidget(widget);

    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsNothing);

    await tester.enterText(find.byType(TextField), 'hi');
    await tester.pump(Duration(milliseconds: 10));

    expect(find.byType(CircularLoading), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('a'), findsNothing);
    expect(find.text('b'), findsWidgets);
  });
}
