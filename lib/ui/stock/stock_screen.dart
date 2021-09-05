import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/circular_loading.dart';
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
      body: stock.isReady
          ? stock.isEmpty
              ? Center(child: EmptyBody(onPressed: navigateNewIngredient))
              : _body(stock)
          : CircularLoading(),
    );
  }

  Widget _body(Stock stock) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ReplenishmentActions(),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: _StockMetadata(stock),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: IngredientList(ingredients: stock.itemList),
        ),
      ),
    ]);
  }
}

class _StockMetadata extends StatelessWidget {
  final Stock stock;

  const _StockMetadata(this.stock);

  @override
  Widget build(BuildContext context) {
    final captionStyle = Theme.of(context).textTheme.caption!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          fit: FlexFit.tight,
          child: Row(
            children: [
              Icon(
                Icons.store_sharp,
                size: captionStyle.fontSize,
                color: captionStyle.color,
              ),
              HintText(
                tt('stock.ingredient.current_amount'),
                overflow: TextOverflow.ellipsis,
              ),
              MetaBlock(),
              Icon(
                Icons.shopping_cart_sharp,
                size: captionStyle.fontSize,
                color: captionStyle.color,
              ),
              HintText(
                tt('stock.ingredient.last_amount'),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Tooltip(
            message: tt('stock.ingredient.updated_at'),
            child: Icon(
              Icons.access_time,
              size: captionStyle.fontSize,
              color: captionStyle.color,
            ),
          ),
        ),
        HintText(stock.updatedDate ?? tt('stock.ingredient.un_add')),
      ],
    );
  }
}
