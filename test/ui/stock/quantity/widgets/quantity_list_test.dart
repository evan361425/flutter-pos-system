import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/stock/quantity/widgets/quantity_list.dart';

void main() {
  testWidgets('should navigate to modal', (tester) async {
    final quantity = QuantityModel(name: 'name');
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
}
