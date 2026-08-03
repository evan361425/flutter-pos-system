import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';

void main() {
  group('Component ReorderableScaffold', () {
    testWidgets('Trigger proxyDecorator with default builder', (WidgetTester tester) async {
      final items = [_Item(name: 'Item 0'), _Item(name: 'Item 1')];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MyReorderableList<_Item>(items: items)),
        ),
      );

      expect(find.byWidgetPredicate((widget) => widget is Material && widget.elevation == 6.0), findsNothing);

      final firstItemFinder = find.byKey(const Key('reorder.0'));
      final gesture = await tester.startGesture(tester.getCenter(firstItemFinder));
      await tester.pump(const Duration(milliseconds: 600));

      await gesture.moveBy(const Offset(0.0, 50.0));
      await tester.pump(); // trigger the proxyDecorator

      expect(find.byWidgetPredicate((widget) => widget is Material && widget.elevation == 6.0), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();

      expect(items[0].name, equals('Item 1'));
      expect(items[1].name, equals('Item 0'));
    });

    testWidgets('Trigger proxyDecorator with itemWhenDraggingBuilder', (WidgetTester tester) async {
      final items = [_Item(name: 'Item 0'), _Item(name: 'Item 1')];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyReorderableList<_Item>(
              items: items,
              itemWhenDraggingBuilder: (context, item, toggler) {
                return const ListTile(title: Text('Hi'));
              },
            ),
          ),
        ),
      );

      final firstItemFinder = find.byKey(const Key('reorder.0'));
      final gesture = await tester.startGesture(tester.getCenter(firstItemFinder));
      await tester.pump(const Duration(milliseconds: 600));

      await gesture.moveBy(const Offset(0.0, 50.0));
      await tester.pump(); // trigger the proxyDecorator

      expect(find.text('Hi'), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();

      expect(items[0].name, equals('Item 1'));
      expect(items[1].name, equals('Item 0'));
    });
  });
}

class _Item {
  final String name;
  _Item({required this.name});
}
