import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/toast.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/ui/cashier/changer/changer_dialog_favorite.dart';

import '../../../mocks/mocks.dart';

void main() {
  testWidgets('should addable if empty', (tester) async {
    when(cashier.favoriteIsEmpty).thenReturn(true);

    var isTapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: ChangerDialogFavorite(handleAdd: () => isTapped = true),
      ),
    ));

    await tester.tap(find.text('立即設定'));
    await tester.pumpAndSettle();

    expect(isTapped, isTrue);
  });

  testWidgets('delete from more', (tester) async {
    final item = CashierChangeBatchObject.fromMap({
      'source': {'unit': 5, 'count': 1},
      'targets': [
        {'unit': 1, 'count': 5},
      ],
    });
    when(cashier.favoriteIsEmpty).thenReturn(false);
    when(cashier.favoriteLength).thenReturn(1);
    when(cashier.favoriteAt(0)).thenReturn(item);

    await tester.pumpWidget(MaterialApp(
      home: Material(child: ChangerDialogFavorite(handleAdd: () {})),
    ));

    await tester.tap(find.byIcon(Icons.more_vert_sharp));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    verify(cashier.deleteFavorite(0));
  });

  testWidgets('delete from long press', (tester) async {
    final item = CashierChangeBatchObject.fromMap({
      'source': {'unit': 5, 'count': 1},
      'targets': [
        {'unit': 1, 'count': 5},
      ],
    });
    when(cashier.favoriteIsEmpty).thenReturn(false);
    when(cashier.favoriteLength).thenReturn(1);
    when(cashier.favoriteAt(0)).thenReturn(item);

    await tester.pumpWidget(MaterialApp(
      home: Material(child: ChangerDialogFavorite(handleAdd: () {})),
    ));

    await tester.longPress(find.text('用 1 個 5 元換'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    verify(cashier.deleteFavorite(0));
  });

  testWidgets('should not valid if not select', (tester) async {
    final item = CashierChangeBatchObject.fromMap({
      'source': {'unit': 5, 'count': 1},
      'targets': [
        {'unit': 1, 'count': 5},
      ],
    });
    when(cashier.favoriteIsEmpty).thenReturn(false);
    when(cashier.favoriteLength).thenReturn(1);
    when(cashier.favoriteAt(0)).thenReturn(item);
    Toast.startDebug();

    final dialog = GlobalKey<ChangerDialogFavoriteState>();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: ChangerDialogFavorite(handleAdd: () {}, key: dialog),
      ),
    ));

    final result = await dialog.currentState?.handleApply();

    expect(result, isFalse);
  });

  setUpAll(() {
    initialize();
  });
}
