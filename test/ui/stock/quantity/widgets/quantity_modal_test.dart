import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/ui/stock/quantity/widgets/quantity_modal.dart';

import '../../../../mocks/mock_widgets.dart';
import '../../../../mocks/mocks.dart';
import '../../../../models/repository/quantity_repo_test.mocks.dart';

void main() {
  testWidgets('should setItem if updating', (tester) async {
    final quantity = MockQuantityModel();
    when(quantity.name).thenReturn('name');
    when(quantity.id).thenReturn('id');
    when(quantity.defaultProportion).thenReturn(1);
    when(quantity.update(any)).thenAnswer((_) => Future.value());

    when(quantities.setItem(quantity)).thenAnswer((_) => Future.value());

    await tester.pumpWidget(bindWithNavigator(QuantityModal(
      quantity: quantity,
    )));

    await tester.tap(find.byType(TextButton));
    verify(quantities.setItem(any)).called(1);
  });

  testWidgets('should add new item', (tester) async {
    when(quantities.setItem(any)).thenAnswer((_) => Future.value());
    when(quantities.hasItem(any)).thenReturn(false);

    await tester.pumpWidget(bindWithNavigator(QuantityModal()));

    await tester.enterText(find.byType(TextFormField).first, 'name');
    await tester.enterText(find.byType(TextFormField).last, '2');

    await tester.tap(find.byType(TextButton));
    verify(quantities.setItem(argThat(predicate<QuantityModel>((object) {
      return object.name == 'name' && object.defaultProportion == 2;
    })))).called(1);
  });

  setUpAll(() {
    initialize();
  });
}
