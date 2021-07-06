import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/models/model_object.dart';

void main() {
  testWidgets('should not handle tap when sliding', (tester) async {
    var tapCount = 0;
    final widget = MaterialApp(
      home: SlidableItemList<MockModel>(
        items: [MockModel('1'), MockModel('2')],
        tileBuilder: (_, item) => Text(item.name),
        warningContextBuilder: (_, __) => Text('hi'),
        handleTap: (_, __) => Future.value(tapCount++),
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
    await tester.pumpWidget(MaterialApp(
      home: SlidableItemList<MockModel>(
        items: [MockModel('1'), MockModel('2')],
        tileBuilder: (_, item) => Text(item.name),
        warningContextBuilder: (_, __) => Text('hi'),
        handleTap: (_, __) => Future.value(),
      ),
    ));

    // show slider action
    await tester.drag(find.text('1'), Offset(-100, 0));
    await tester.pumpAndSettle();

    // tap delete icon
    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    expect(find.byType(DeleteDialog), findsOneWidget);
  });
}

class MockModel with Model<MockObject> {
  MockModel(this.name);

  @override
  final String name;

  @override
  String get code => '123';

  @override
  void removeFromRepo() => null;

  @override
  Stores get storageStore => Stores.menu;

  @override
  MockObject toObject() => MockObject();

  @override
  Future<void> update(ModelObject object) => Future.value();
}

class MockObject with ModelObject<MockModel> {
  @override
  Map<String, Object> diff(MockModel model) => {};

  @override
  Map<String, Object?> toMap() => {};
}
