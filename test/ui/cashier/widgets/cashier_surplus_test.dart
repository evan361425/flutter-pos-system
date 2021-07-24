import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/ui/cashier/widgets/cashier_surplus.dart';

import '../../../mocks/mocks.dart';

void main() {
  testWidgets('should show sign', (tester) async {
    Cashier.instance = Cashier();

    await Cashier.instance.setCurrent([
      {'unit': 1, 'count': 3},
      {'unit': 5, 'count': 3},
    ], []);
    await Cashier.instance.setDefault(record: [
      {'unit': 1, 'count': 2},
      {'unit': 5, 'count': 5},
    ]);

    await tester.pumpWidget(
      MaterialApp(home: SingleChildScrollView(child: CashierSurplus())),
    );

    expect(find.text('+1'), findsOneWidget);
    expect(find.text('-2'), findsOneWidget);

    Cashier.instance = cashier;
  });
}
