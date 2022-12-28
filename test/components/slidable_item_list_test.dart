import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/translator.dart';

import '../test_helpers/translator.dart';

void main() {
  group('Widget SlidableItemList', () {
    testWidgets('should not handle tap when sliding', (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: SlidableAutoCloseBehavior(
          child: SlidableItemList<String, int>(
            delegate: SlidableItemDelegate(
              groupTag: 'test',
              items: const ['1', '2'],
              deleteValue: 0,
              tileBuilder: (_, int index, item, __) => Text(item),
              warningContextBuilder: (_, __) => const Text('hi'),
              handleTap: (_, __) => Future.value(tapCount++),
              handleDelete: (_) => Future.value(),
            ),
          ),
        ),
      ));

      final action = find.byKey(const Key('slidable.test.0'));
      expect(action, findsNothing);

      // swipe to left
      await tester.drag(find.text('1'), const Offset(-150, 0));
      await tester.pumpAndSettle();

      expect(action, findsOneWidget);

      await tester.tap(find.text('1'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(action, findsNothing);
      expect(tapCount, equals(0));

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(tapCount, equals(1));
    });

    testWidgets('should show alert when delete', (tester) async {
      var deletionFired = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SlidableItemList<String, int>(
            delegate: SlidableItemDelegate(
              groupTag: 'test',
              items: const ['1', '2'],
              deleteValue: 0,
              tileBuilder: (_, int index, item, __) => Text(item),
              warningContextBuilder: (_, __) => const Text('hi'),
              handleTap: (_, __) => Future.value(),
              handleDelete: (_) async => deletionFired = true,
            ),
          ),
        ),
      ));

      await tester.drag(find.text('1'), const Offset(-150, 0));
      await tester.pumpAndSettle();

      // tap delete icon
      await tester.tap(find.byKey(const Key('slidable.test.0')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.btnDelete));
      await tester.pumpAndSettle();

      expect(deletionFired, isTrue);
    });

    test('estimated child count should be same as items length', () {
      final delegate = SlidableItemDelegate<String, int>(
        items: ['A', 'B'],
        deleteValue: 0,
        tileBuilder: (ctx, idx, val, d) => const SizedBox.shrink(),
        handleDelete: (val) => Future.value(),
      );
      final builder = SliverSlidableItemBuilder(delegate);

      expect(builder.estimatedChildCount, 2);
    });

    setUpAll(() {
      initializeTranslator();
    });
  });
}
