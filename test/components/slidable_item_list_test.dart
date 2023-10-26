import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/translator.dart';

import '../test_helpers/translator.dart';

void main() {
  group('Widget SlidableItemList', () {
    testWidgets('should show alert when delete', (tester) async {
      var deletionFired = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SlidableItemList<String, int>(
            delegate: SlidableItemDelegate(
              items: const ['1', '2'],
              deleteValue: 0,
              tileBuilder: (_, item, int index, __) => Text(item),
              confirmContextBuilder: (_, __) => const Text('hi'),
              handleDelete: (_) async => deletionFired = true,
            ),
          ),
        ),
      ));

      await tester.drag(find.text('1'), const Offset(-1000, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.btnDelete));
      await tester.pumpAndSettle();

      expect(deletionFired, isTrue);
    });

    setUpAll(() {
      initializeTranslator();
    });
  });
}
