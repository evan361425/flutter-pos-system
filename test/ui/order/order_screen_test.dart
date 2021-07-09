import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/ui/order/order_screen.dart';

import '../../mocks/mocks.dart';

void main() {
  testWidgets('should show actions', (tester) async {
    when(menu.setUpStockMode(any)).thenReturn(false);

    await tester.pumpWidget(MaterialApp(home: OrderScreen()));

    await tester.tap(find.byIcon(KIcons.more));
    await tester.pump();

    expect(find.byIcon(Icons.cancel_sharp), findsOneWidget);
  });

  testWidgets('should show dialog when order', (tester) async {});

  testWidgets('should buildable in landscape mode', (tester) async {});

  testWidgets('should update products when select catalog', (tester) async {});

  testWidgets('should scroll to bottom when select product', (tester) async {});

  setUpAll(() {
    initialize();
  });
}
