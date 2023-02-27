import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/ingredient_list.dart';

class StockScreen<T> extends StatefulWidget {
  final TutorialInTab? tab;

  const StockScreen({
    Key? key,
    this.tab,
  }) : super(key: key);

  @override
  State<StockScreen<T>> createState() => _StockScreenState<T>();
}

class _StockScreenState<T> extends State<StockScreen<T>> {
  final antAdd = Tutorial.buildAnt();
  final gaffer = Tutorial.buildAnt();

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<Stock>();

    if (stock.isEmpty) {
      return Center(
        key: const Key('stock.empty'),
        child: EmptyBody(
          tooltip: '新增成份後，就可以開始追蹤這些成份的庫存囉！',
          onPressed: () => Navigator.of(context).pushNamed(
            Routes.stockIngredient,
          ),
        ),
      );
    }

    return ListView(children: [
      Flex(direction: Axis.horizontal, children: [
        Expanded(
          child: Tutorial(
            id: 'stock.replenishment',
            ant: gaffer,
            ants: [antAdd, gaffer],
            startNow: false,
            title: '成份採購',
            message: '你不需要一個一個去設定庫存！\n' '馬上設定採購，一次調整多個成份吧！',
            child: const RouteCircularButton(
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
          child: Tutorial(
            ant: antAdd,
            id: 'stock.add',
            disable: Stock.instance.isNotEmpty,
            title: '新增成份',
            message: '成份可以幫助我們確認相關產品的庫存！',
            child: RouteCircularButton(
              key: const Key('stock.add'),
              route: Routes.stockIngredient,
              icon: KIcons.add,
              text: S.stockIngredientCreate,
            ),
          ),
        ),
      ]),
      const SizedBox(height: 4.0),
      IngredientList(ingredients: Stock.instance.itemList),
    ]);
  }

  @override
  void initState() {
    super.initState();

    widget.tab?.bindAnt(gaffer, startNow: true);
  }
}
