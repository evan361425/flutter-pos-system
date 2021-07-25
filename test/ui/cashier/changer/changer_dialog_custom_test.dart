import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/toast.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/ui/cashier/changer/changer_dialog_custom.dart';

import '../../../mocks/mocks.dart';
import '../../../mocks/providers.dart';

void main() {
  testWidgets('change unit only and handle favorite', (tester) async {
    when(currency.unitList).thenReturn([1, 5, 10]);
    when(cashier.findPossibleChange(1, 10))
        .thenReturn(CashierChangeEntryObject(unit: 5, count: 2));

    var added = false;
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: ChangerDialogCustom(
          handleFavoriteAdded: () => added = true,
        ),
      ),
    ));

    await tester.tap(find.byKey(Key('changer.source')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('10').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('新增常用'));
    await tester.pumpAndSettle();

    expect(added, isTrue);
    verify(
      cashier.addFavorite(argThat(predicate<CashierChangeBatchObject>((item) {
        final target = item.targets.first;
        return item.source.count == 1 &&
            item.source.unit == 10 &&
            target.unit == 5 &&
            target.count == 2;
      }))),
    );
  });

  testWidgets('add target and merge correctly', (tester) async {
    when(currency.unitList).thenReturn([1, 5, 10]);
    when(cashier.findPossibleChange(1, 10))
        .thenReturn(CashierChangeEntryObject(unit: 5, count: 2));
    when(cashier.findPossibleChange(5, 10))
        .thenReturn(CashierChangeEntryObject(unit: 5, count: 10));
    final dialog = GlobalKey<ChangerDialogCustomState>();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: ChangerDialogCustom(key: dialog, handleFavoriteAdded: () {}),
      ),
    ));

    await tester.tap(find.byKey(Key('changer.source')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('10').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '5');
    await tester.pumpAndSettle();

    // add two targets, total targets: 3
    await tester.tap(find.byIcon(KIcons.add));
    await tester.tap(find.byIcon(KIcons.add));
    await tester.pumpAndSettle();

    // select 5 on second target
    await tester.enterText(find.byType(TextFormField).at(2), '1');
    await tester.tap(find.byKey(Key('changer.target.1')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('5').last);
    await tester.pumpAndSettle();

    // select 1 on third target
    await tester.enterText(find.byType(TextFormField).last, '5');
    await tester.tap(find.byKey(Key('changer.target.2')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();

    // 5*10 is not able to change 10*5 + 1*5 + 5*1
    final shouldFalse = await dialog.currentState?.handleApply();
    expect(shouldFalse, isFalse);
    verifyNever(cashier.validate(any, any));

    // change count to 8 on first target
    await tester.enterText(find.byType(TextFormField).at(1), '8');

    // 5*10 is now able to change 8*5 + 1*5 + 5*1
    when(cashier.validate(2, 5)).thenReturn(true);
    when(cashier.indexOf(10)).thenReturn(2);
    when(cashier.indexOf(5)).thenReturn(1);
    when(cashier.indexOf(1)).thenReturn(0);
    final shouldTrue = await dialog.currentState?.handleApply();
    // wait for toast
    await tester.pump(Duration(seconds: 2, milliseconds: 500));

    expect(shouldTrue, isTrue);
    verify(cashier.update(argThat(equals({2: -5, 1: 9, 0: 5}))));
  });

  setUpAll(() {
    initialize();
    initializeProviders();
  });
}
