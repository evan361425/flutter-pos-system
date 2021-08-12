import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/stock/quantity/widgets/quantity_list.dart';

import '../../../../mocks/mock_models.mocks.dart';
import '../../../../mocks/mock_repos.dart';
import '../../../../mocks/mock_storage.dart';

void main() {
  testWidgets('should navigate to modal', (tester) async {
    final quantity = Quantity(name: 'name');
    var argument;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.stockQuantityModal: (context) {
          argument = ModalRoute.of(context)!.settings.arguments;
          return Container();
        },
      },
      home: QuantityList(
        quantities: [quantity],
      ),
    ));

    // tap tile
    await tester.tap(find.text('name'));
    await tester.pumpAndSettle();

    expect(identical(quantity, argument), isTrue);
  });

  testWidgets('delete quantity', (tester) async {
    final qua1 = Quantity(name: 'qua1', id: 'qua1');
    final qua2 = Quantity(name: 'qua2', id: 'qua2');
    final pQua = MockProductQuantity();
    LOG_LEVEL = 0;
    when(menu.removeQuantities(any)).thenAnswer((_) => Future.value());
    when(menu.getQuantities('qua1')).thenReturn([]);
    when(menu.getQuantities('qua2')).thenReturn([pQua]);
    when(storage.set(any, any)).thenAnswer((_) => Future.value());

    await tester.pumpWidget(MaterialApp(
      home: QuantityList(quantities: [qua1, qua2]),
    ));

    // delete qua1
    await tester.drag(find.text('qua1'), Offset(-300, 0));
    await tester.pump();

    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    // not delete qua2
    await tester.drag(find.text('qua2'), Offset(-300, 0));
    await tester.pump();

    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();

    await tester.tap(find.text('cancel'));
    await tester.pumpAndSettle();

    verify(menu.removeQuantities('qua1'));
    verifyNever(menu.removeQuantities('qua2'));
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
