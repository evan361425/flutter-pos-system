import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/ui/cashier/widgets/cashier_unit_list.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mock_repos.dart';
import '../../../mocks/mock_storage.dart';

void main() {
  testWidgets('should add successfully', (tester) async {
    Cashier.instance = Cashier();
    when(storage.set(any, any)).thenAnswer((_) => Future.value());

    await Cashier.instance.setCurrent([
      {'unit': 1, 'count': 3},
    ], []);

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: Cashier.instance,
      child: MaterialApp(home: Material(child: CashierUnitList())),
    ));

    await tester.tap(find.byIcon(KIcons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '5');
    await tester.tap(find.text('confirm'));
    await tester.pumpAndSettle();

    expect(Cashier.instance.at(0).count, 8);

    Cashier.instance = cashier;
  });

  testWidgets('should minus successfully', (tester) async {
    Cashier.instance = Cashier();
    when(storage.set(any, any)).thenAnswer((_) => Future.value());

    await Cashier.instance.setCurrent([
      {'unit': 1, 'count': 3},
    ], []);

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: Cashier.instance,
      child: MaterialApp(home: Material(child: CashierUnitList())),
    ));

    await tester.tap(find.byIcon(KIcons.remove));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '5');
    await tester.tap(find.text('confirm'));
    await tester.pumpAndSettle();

    expect(Cashier.instance.at(0).count, 0);

    Cashier.instance = cashier;
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
