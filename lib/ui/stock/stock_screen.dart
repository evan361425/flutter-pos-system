import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/widgets/ingredient_list.dart';
import 'package:possystem/ui/stock/widgets/replenishment_actions.dart';
import 'package:provider/provider.dart';

class StockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stock = context.watch<Stock>();

    final navigateNewIngredient =
        () => Navigator.of(context).pushNamed(Routes.stockIngredient);

    return Scaffold(
      appBar: AppBar(
        title: Text(tt('home.stock')),
        leading: PopButton(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateNewIngredient,
        tooltip: tt('stock.ingredient.add'),
        child: Icon(KIcons.add),
      ),
      // this page need to draw lots of data, wait a will to make sure page shown
      body: stock.isEmpty
          ? Center(child: EmptyBody(onPressed: navigateNewIngredient))
          : _body(stock),
    );
  }

  Widget _body(Stock stock) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(children: [
          ReplenishmentActions(),
          HintText(tt('total_count', {'count': stock.length})),
          HintText('上次補貨時間：${stock.updatedDate ?? '無'}'),
        ]),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: IngredientList(ingredients: stock.itemList),
        ),
      ),
    ]);
  }
}
