import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/radio_text.dart';

void main() {
  testWidgets('should work like radio', (WidgetTester tester) async {
    var selected = 0;
    final radios = [
      for (var i = 0; i < 5; i++)
        RadioText(
          groupId: 'some-id',
          onSelected: () => selected = i,
          value: i.toString(),
          text: i.toString(),
        )
    ];

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Material(child: Row(children: radios)),
    ));

    expect(radios[0].isSelected, isTrue);
    expect(selected, equals(0));

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(radios[0].isSelected, isFalse);
    expect(radios[1].isSelected, isTrue);
    expect(selected, equals(1));
  });

  testWidgets('should not selected all', (WidgetTester tester) async {
    final radios = [
      for (var i = 0; i < 5; i++)
        RadioText(
          groupId: 'some-id',
          onSelected: () {},
          value: i.toString(),
          isSelected: false,
          text: i.toString(),
        )
    ];

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Material(child: Row(children: radios)),
    ));

    expect(radios.every((element) => element.isSelected == false), isTrue);
  });

  testWidgets('should selected specific one', (WidgetTester tester) async {
    final selected = 2;
    final radios = [
      for (var i = 0; i < 5; i++)
        RadioText(
          groupId: 'some-id',
          onSelected: () {},
          value: i.toString(),
          isSelected: selected == i,
          text: i.toString(),
        )
    ];

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Material(child: Row(children: radios)),
    ));

    expect(radios[selected].isSelected, isTrue);

    // should select none
    RadioText(
      groupId: 'some-id',
      onSelected: () {},
      value: '2',
      isSelected: false,
      text: 'hi',
    );

    expect(radios[selected].isSelected, isFalse);
  });
}
