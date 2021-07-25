import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/ui/stock/quantity/widgets/quantity_modal.dart';

import '../../../../mocks/mock_storage.dart';
import '../../../../mocks/mock_widgets.dart';
import '../../../../mocks/mock_repos.dart';

void main() {
  testWidgets('should setItem if updating', (tester) async {
    final quantity = Quantity(name: 'name', id: 'id');

    when(quantities.setItem(quantity)).thenAnswer((_) => Future.value());
    when(quantities.hasName('name-new')).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(QuantityModal(
      quantity: quantity,
    )));

    await tester.enterText(find.byType(TextFormField).first, 'name-new');
    await tester.enterText(find.byType(TextFormField).last, '3');

    await tester.tap(find.byType(TextButton));

    verify(storage.set(any, argThat(predicate<Map<String, Object>>((map) {
      return map['id.name'] == 'name-new' && map['id.defaultProportion'] == 3;
    })))).called(1);
    verify(quantities.setItem(any));
  });

  testWidgets('should add new item', (tester) async {
    when(quantities.setItem(any)).thenAnswer((_) => Future.value());
    when(quantities.hasName(any)).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(QuantityModal()));

    await tester.enterText(find.byType(TextFormField).first, 'name');
    await tester.enterText(find.byType(TextFormField).last, '2');

    await tester.tap(find.byType(TextButton));
    verify(quantities.setItem(argThat(predicate<Quantity>((object) {
      return object.name == 'name' && object.defaultProportion == 2;
    })))).called(1);
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
