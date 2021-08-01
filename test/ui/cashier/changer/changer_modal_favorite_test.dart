import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/ui/cashier/changer/changer_modal_favorite.dart';

import '../../../mocks/mock_repos.dart';

void main() {
  testWidgets('should addable if empty', (tester) async {
    when(cashier.favoriteIsEmpty).thenReturn(true);

    var isTapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: ChangerModalFavorite(handleAdd: () => isTapped = true),
      ),
    ));

    await tester.tap(find.text('立即設定'));
    await tester.pumpAndSettle();

    expect(isTapped, isTrue);
  });

  testWidgets('delete from more', (tester) async {
    when(cashier.favoriteIsEmpty).thenReturn(false);

    await tester.pumpWidget(MaterialApp(
      home: Material(child: ChangerModalFavorite(handleAdd: () {})),
    ));

    await tester.tap(find.byIcon(Icons.more_vert_sharp));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    verify(cashier.deleteFavorite(0));
  });

  testWidgets('should not valid if not select', (tester) async {
    when(cashier.favoriteIsEmpty).thenReturn(false);

    final dialog = GlobalKey<ChangerModalFavoriteState>();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: ChangerModalFavorite(handleAdd: () {}, key: dialog),
      ),
    ));

    final result = await dialog.currentState?.handleApply();
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  setUp(() {
    when(cashier.favoriteItems()).thenReturn([
      FavoriteItem(
        item: CashierChangeBatchObject.fromMap({
          'source': {'unit': 5, 'count': 1},
          'targets': [
            {'unit': 1, 'count': 5},
          ],
        }),
        index: 0,
      )
    ]);
  });

  setUpAll(() {
    initializeRepos();
  });
}
