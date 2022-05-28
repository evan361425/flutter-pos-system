import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/ingredient_list.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<Stock>();

    if (stock.isEmpty) {
      return Center(
        key: const Key('stock.empty'),
        child: EmptyBody(
          onPressed: () => Navigator.of(context).pushNamed(
            Routes.stockIngredient,
          ),
        ),
      );
    }

    return ListView(children: [
      Flex(direction: Axis.horizontal, children: [
        const Expanded(
          child: Tooltip(
            message: '你不需要一個一個去設定庫存，馬上設定採購，一次設定多個成份吧！',
            child: RouteCircularButton(
              key: Key('stock.replenisher'),
              icon: Icons.shopping_basket_sharp,
              route: Routes.stockReplenishment,
              popTrueShowSuccess: true,
              text: '採購',
            ),
          ),
        ),
        const Spacer(flex: 2),
        Expanded(
          child: RouteCircularButton(
            key: const Key('stock.add'),
            route: Routes.stockIngredient,
            icon: KIcons.add,
            text: S.stockIngredientCreate,
          ),
        ),
      ]),
      const SizedBox(height: 4.0),
      IngredientList(ingredients: Stock.instance.itemList),
    ]);
  }
}
