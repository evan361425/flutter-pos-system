import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/widgets/stock_ingredient_list.dart';

// every time push a new page, the page will rebuild, so cache the child widget
// ignore: must_be_immutable
class StockView extends StatelessWidget {
  final int? tabIndex;

  Widget? child;

  StockView({super.key, this.tabIndex});

  @override
  Widget build(BuildContext context) {
    // after pop from AddPage, this page will rebuild by TabView
    // so we don't need to watch Stock.instance
    if (Stock.instance.isEmpty) {
      return Center(
        key: const Key('stock.empty'),
        child: EmptyBody(
          helperText: '新增成份後，就可以開始追蹤這些成份的庫存囉！',
          onPressed: () => context.pushNamed(Routes.ingredientNew),
        ),
      );
    }

    return child ??= _build(context);
  }

  Widget _build(BuildContext context) {
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
        ListenableBuilder(
          listenable: Stock.instance,
          builder: (context, child) {
            return StockIngredientList(ingredients: Stock.instance.itemList);
          },
        ),
      ]),
    );
  }
}
