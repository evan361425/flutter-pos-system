import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:simple_tip/simple_tip.dart';

import 'widgets/ingredient_list.dart';

class StockScreen extends StatelessWidget {
  final GlobalKey<TipGrouperState>? tipGrouper;

  final RouteObserver<ModalRoute<void>>? routeObserver;

  const StockScreen({
    Key? key,
    this.routeObserver,
    this.tipGrouper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<Stock>();

    final body = stock.isEmpty
        ? Center(
            child: EmptyBody(
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.stockIngredient,
            ),
          ))
        : _StockBody(tipGrouper: tipGrouper);

    return TipGrouper(
      key: tipGrouper,
      id: 'stock',
      candidateLength: 1,
      routeObserver: routeObserver,
      child: body,
    );
  }
}

class _StockBody extends StatelessWidget {
  final GlobalKey<TipGrouperState>? tipGrouper;

  const _StockBody({Key? key, this.tipGrouper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final updatedAt = Stock.instance.updatedAt;

    return ListView(children: [
      const SizedBox(height: 4.0),
      Center(
        child: HintText(updatedAt == null
            ? S.stockHasNotReplenishEver
            : S.stockUpdatedAt(updatedAt)),
      ),
      const SizedBox(height: 4.0),
      Flex(direction: Axis.horizontal, children: [
        Expanded(
          child: OrderedTip(
            grouper: tipGrouper,
            id: 'replenishment',
            order: 2,
            version: 1,
            message: '你不需要一個一個去設定庫存，馬上設定採購，一次設定多個成份吧！',
            child: const RouteCircularButton(
              key: Key('stock.replenisher'),
              icon: Icons.shopping_basket_sharp,
              route: Routes.stockReplenishment,
              popTrueShowSuccess: true,
              text: '採購',
            ),
          ),
        ),
        Expanded(
          child: RouteCircularButton(
            key: const Key('stock.add'),
            route: Routes.stockIngredient,
            icon: KIcons.add,
            text: S.stockIngredientCreate,
          ),
        ),
        const Spacer(flex: 2),
      ]),
      const SizedBox(height: 4.0),
      IngredientList(ingredients: Stock.instance.itemList),
    ]);
  }
}
