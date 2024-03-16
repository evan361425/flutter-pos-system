import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/stock_ingredient_list.dart';

class StockView<T> extends StatelessWidget {
  final int? tabIndex;

  const StockView({super.key, this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<Stock>();

    if (stock.isEmpty) {
      return Center(
        key: const Key('stock.empty'),
        child: EmptyBody(
          helperText: '新增成份後，就可以開始追蹤這些成份的庫存囉！',
          onPressed: () => context.pushNamed(Routes.ingredientNew),
        ),
      );
    }

    final tab = tabIndex == null
        ? null
        : TutorialInTab(index: tabIndex!, context: context);

    return TutorialWrapper(
      tab: tab,
      child: ListView(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Tutorial(
            id: 'stock.replenishment',
            index: 1,
            title: S.stockReplenishmentTutorialTitle,
            message: S.stockReplenishmentTutorialMessage,
            child: RouteCircularButton(
              key: const Key('stock.replenisher'),
              icon: Icons.shopping_basket_sharp,
              route: Routes.replenishment,
              popTrueShowSuccess: true,
              text: S.stockReplenishmentButton,
            ),
          ),
          const SizedBox.square(dimension: 96.0),
          Tutorial(
            id: 'stock.add',
            index: 0,
            disable: Stock.instance.isNotEmpty,
            title: S.stockIngredientAddTutorialTitle,
            message: S.stockIngredientAddTutorialMessage,
            child: RouteCircularButton(
              key: const Key('stock.add'),
              route: Routes.ingredientNew,
              icon: KIcons.add,
              text: S.stockIngredientCreate,
            ),
          ),
        ]),
        const SizedBox(height: 4.0),
        StockIngredientList(ingredients: Stock.instance.itemList),
      ]),
    );
  }
}
