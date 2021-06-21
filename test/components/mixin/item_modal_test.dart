import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/mixin/item_modal.dart';

void main() {
  testWidgets('should not update while saving', (WidgetTester tester) async {
    var updateCounter = 0;
    final updateItem = () {
      updateCounter++;
      return Future.delayed(Duration(seconds: 1));
    };
    final validate = () => null;
    final widget = MaterialApp(
        home: ExampleModal(updateItem: updateItem, validate: validate));

    await tester.pumpWidget(widget);

    // start save
    await tester.tap(find.byType(TextButton));
    await tester.pump(Duration(milliseconds: 10));

    // save twice
    await tester.tap(find.byType(TextButton));
    await tester.pump(Duration(seconds: 1));

    expect(updateCounter, equals(1));
  });

  testWidgets('should not update when invalid', (WidgetTester tester) async {
    var updateCounter = 0;
    final updateItem = () {
      updateCounter++;
      return Future.value();
    };
    final validate = () => 'This is invalid!';
    final widget = MaterialApp(
        home: ExampleModal(updateItem: updateItem, validate: validate));

    await tester.pumpWidget(widget);

    // start save
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(updateCounter, equals(0));
  });
}

class ExampleModal extends StatefulWidget {
  ExampleModal({
    Key? key,
    required this.updateItem,
    required this.validate,
  }) : super(key: key);

  final Future<void> Function() updateItem;
  final String? Function() validate;

  @override
  _ExampleModalState createState() => _ExampleModalState();
}

class _ExampleModalState extends State<ExampleModal>
    with ItemModal<ExampleModal> {
  @override
  Future<void> updateItem() => widget.updateItem();

  @override
  // always pass
  String? validate() => widget.validate();

  @override
  List<Widget> formFields() => const [Text('hi')];
}
