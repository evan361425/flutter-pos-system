import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/services/storage.dart';

void main() {
  Widget createWidget(Widget widget) {
    return Material(child: MaterialApp(home: widget));
  }

  testWidgets('should reorder correctly', (WidgetTester tester) async {
    late List<MockModel> finalResult;
    final widget = createWidget(ReorderableScaffold(
      handleSubmit: (List<MockModel> items) async => finalResult = items,
      items: [
        for (var i = 1; i < 6; i++) MockModel(index: i, name: i.toString())
      ],
    ));

    await tester.pumpWidget(widget);

    // 1 to last
    await tester.drag(
        find.byIcon(Icons.reorder_sharp).first, const Offset(0.0, 500.0));
    await tester.pumpAndSettle();

    // 3 to last
    await tester.drag(
        find.byIcon(Icons.reorder_sharp).at(1), const Offset(0.0, 500.0));
    await tester.pumpAndSettle();

    // 5 to first
    await tester.drag(
        find.byIcon(Icons.reorder_sharp).at(2), const Offset(0.0, -500.0));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(
      finalResult,
      equals(
        [5, 2, 4, 1, 3]
            .map((i) => MockModel(index: i, name: i.toString()))
            .toList(),
      ),
    );
  });
}

class MockObject with ModelObject<MockModel> {
  @override
  Map<String, Object> diff(model) => {};

  @override
  Map<String, Object?> toMap() => {};
}

class MockModel extends NotifyModel<MockObject> with OrderableModel {
  MockModel({String? id, required this.index, required this.name}) : super(id);

  @override
  final int index;

  @override
  final String name;

  @override
  String get code => 'hi';

  @override
  void removeFromRepo() {}

  @override
  Stores get storageStore => Stores.menu;

  @override
  MockObject toObject() => MockObject();

  @override
  bool operator ==(Object other) => other is MockModel && index == other.index;

  @override
  String toString() => name;
}
