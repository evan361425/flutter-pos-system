import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/components/style/circular_loading.dart';

void main() {
  testWidgets('should show spinner', (WidgetTester tester) async {
    Future<List<int>> generator() =>
        Future.delayed(Duration(seconds: 1)).then((value) => [0, 1, 2, 3, 4]);
    Widget itemBuilder(_, i) => ListTile(title: Text(i.toString()));

    final widget = MaterialApp(
        home: SearchScaffold<int>(
            handleChanged: (text) => generator(),
            itemBuilder: itemBuilder,
            emptyBuilder: (_, text) => Text(text),
            initialData: generator));
    await tester.pumpWidget(widget);

    expect(find.byType(CircularLoading), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularLoading), findsNothing);

    await tester.enterText(find.byType(TextField), 'hi');
    await tester.pump(Duration(milliseconds: 10));

    expect(find.byType(CircularLoading), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularLoading), findsNothing);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });
}
