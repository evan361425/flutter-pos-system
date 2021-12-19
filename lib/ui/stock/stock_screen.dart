import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/route_tile.dart';
import 'package:possystem/components/style/snackbar.dart';
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

    navigateNewIngredient() =>
        Navigator.of(context).pushNamed(Routes.stockIngredient);

    return TipGrouper(
      key: tipGrouper,
      id: 'stock',
      candidateLength: 1,
      routeObserver: routeObserver,
      child: Scaffold(
        floatingActionButton: OrderedTip(
          grouper: tipGrouper,
          id: 'introduction',
          order: 1,
          version: 1,
          message: '庫存系統可以幫助計算現有庫存\n同時設定成分的相關資訊。',
          child: FloatingActionButton(
            key: const Key('stock.add'),
            onPressed: navigateNewIngredient,
            tooltip: S.stockIngredientCreate,
            child: const Icon(KIcons.add),
          ),
        ),
        // this page need to draw lots of data, wait a will to make sure page shown
        body: stock.isEmpty
            ? Center(child: EmptyBody(onPressed: navigateNewIngredient))
            : _StockBody(tipGrouper: tipGrouper),
      ),
    );
  }
}

class _StockBody extends StatelessWidget {
  final GlobalKey<TipGrouperState>? tipGrouper;

  const _StockBody({Key? key, this.tipGrouper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final updatedAt = Stock.instance.updatedAt;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(children: [
          HintText(updatedAt == null
              ? S.stockHasNotReplenishEver
              : S.stockUpdatedAt(updatedAt)),
          OrderedTip(
            grouper: tipGrouper,
            id: 'replenishment',
            order: 2,
            version: 1,
            message: '你不需要一個一個去設定庫存，馬上設定採購，一次設定多個成份吧！',
            child: const RouteTile(
              key: Key('stock.replenisher'),
              icon: Icons.shopping_basket_sharp,
              route: Routes.stockReplenishment,
              popTrueShowSuccess: true,
              title: '採購',
            ),
          ),
        ]),
      ),
      Expanded(child: IngredientList(ingredients: Stock.instance.itemList)),
    ]);
  }
}
