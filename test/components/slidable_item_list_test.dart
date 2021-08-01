import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/constants/icons.dart';

void main() {
  testWidgets('should not handle tap when sliding', (tester) async {
    var tapCount = 0;
    final widget = MaterialApp(
      home: SlidableItemList<String>(
        items: ['1', '2'],
        tileBuilder: (_, item) => Text(item),
        warningContextBuilder: (_, __) => Text('hi'),
        handleTap: (_, __) => Future.value(tapCount++),
        handleDelete: (_, __) => Future.value(),
      ),
    );

    await tester.pumpWidget(widget);

    expect(find.byIcon(KIcons.delete), findsNothing);

    // swipe to left
    await tester.drag(find.text('1'), Offset(-50, 0));
    await tester.pumpAndSettle();

    expect(find.byIcon(KIcons.delete), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(tapCount, equals(0));

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(tapCount, equals(1));
  });

  testWidgets('should show alert when delete', (tester) async {
    var deletionFired = false;
    await tester.pumpWidget(MaterialApp(
      home: SlidableItemList<String>(
        items: ['1', '2'],
        tileBuilder: (_, item) => Text(item),
        warningContextBuilder: (_, __) => Text('hi'),
        handleTap: (_, __) => Future.value(),
        handleDelete: (_, __) async => deletionFired = true,
      ),
    ));

    // show slider action
    await tester.drag(find.text('1'), Offset(-100, 0));
    await tester.pumpAndSettle();

    // tap delete icon
    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    expect(deletionFired, isTrue);
  });
}
