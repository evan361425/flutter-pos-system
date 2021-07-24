import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/ui/cashier/changer/changer_dialog.dart';

import '../../../mocks/mocks.dart';
import '../../../mocks/providers.dart';

void main() {
  testWidgets('should get true after pop', (tester) async {
    final item = CashierChangeBatchObject.fromMap({
      'source': {'unit': 5, 'count': 1},
      'targets': [
        {'unit': 1, 'count': 5},
      ],
    });
    when(currency.unitList).thenReturn([]);
    when(cashier.favoriteIsEmpty).thenReturn(false);
    when(cashier.favoriteLength).thenReturn(1);
    when(cashier.favoriteAt(0)).thenReturn(item);
    when(cashier.applyFavorite(item)).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => TextButton(
                onPressed: () => showDialog<bool>(
                      context: context,
                      builder: (_) => ChangerDialog(),
                    ).then((value) => expect(value, isTrue)),
                child: Text('hi')))));

    await tester.tap(find.text('hi'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('用 1 個 5 元換'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('套用'));
    await tester.pumpAndSettle();

    expect(find.text('cancel'), findsNothing);
  });

  setUpAll(() {
    initialize();
  });
}
