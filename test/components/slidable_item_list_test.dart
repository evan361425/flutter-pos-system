import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/slidable_item_list.dart';

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
              tileBuilder: (item, int index, __) => Text(item),
              warningContentBuilder: (_, __) => const Text('hi'),
              handleDelete: (_) async => deletionFired = true,
            ),
          ),
        ),
      ));

      await tester.drag(find.text('1'), const Offset(-1000, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deletionFired, isTrue);
    });

    testWidgets('should handle actions', (tester) async {
      int tappedAction = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SlidableItemList<String, int>(
            delegate: SlidableItemDelegate(
              items: const ['1'],
              deleteValue: 0,
              tileBuilder: (item, int index, actorBuilder) {
                return Builder(builder: (context) {
                  return ListTile(title: Text(item), onTap: actorBuilder(context));
                });
              },
              handleDelete: (_) async {},
              actionBuilder: (item) => [
                const BottomSheetAction<int>(
                  title: Text('Hi'),
                  leading: Icon(Icons.ac_unit),
                  returnValue: 1,
                ),
              ],
              handleAction: (item, action) {
                tappedAction = action;
              },
            ),
          ),
        ),
      ));

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hi'));
      await tester.pumpAndSettle();

      expect(tappedAction, equals(1));
    });

    setUpAll(() {
      initializeTranslator();
    });
  });
}
