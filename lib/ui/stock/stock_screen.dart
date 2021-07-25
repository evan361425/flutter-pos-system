import 'package:flutter/material.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/widgets/ingredient_list.dart';
import 'package:possystem/ui/stock/widgets/replenishment_actions.dart';
import 'package:provider/provider.dart';

class StockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tt('home.stock')),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(Routes.stockIngredient),
        tooltip: tt('stock.ingredient.add'),
        child: Icon(KIcons.add),
      ),
      body: FutureBuilder<bool>(
        future: Future.delayed(Duration(milliseconds: 10), () => true),
        builder: (context, snapshot) {
          return snapshot.hasData ? _body(context) : CircularLoading();
        },
      ),
    );
  }

  Widget _body(BuildContext context) {
    final stock = context.watch<Stock>();
    if (!stock.isReady) return CircularLoading();
    if (stock.isEmpty) {
      return Center(
        child: EmptyBody(body: Text(tt('stock.ingredient.empty'))),
      );
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ReplenishmentActions(),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: _metadata(context),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: IngredientList(ingredients: stock.itemList),
        ),
      ),
    ]);
  }

  Widget _metadata(BuildContext context) {
    final mutedStyle = Theme.of(context).textTheme.muted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          fit: FlexFit.tight,
          child: Row(
            children: [
              Icon(
                Icons.store_sharp,
                size: mutedStyle.fontSize,
                color: mutedStyle.color,
              ),
              Text(
                tt('stock.ingredient.current_amount'),
                style: mutedStyle,
                overflow: TextOverflow.ellipsis,
              ),
              MetaBlock(),
              Icon(
                Icons.shopping_cart_sharp,
                size: mutedStyle.fontSize,
                color: mutedStyle.color,
              ),
              Text(
                tt('stock.ingredient.last_amount'),
                style: mutedStyle,
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
              size: mutedStyle.fontSize,
              color: mutedStyle.color,
            ),
          ),
        ),
        Text(
          Stock.instance.updatedDate ?? tt('stock.ingredient.un_add'),
          style: mutedStyle,
        ),
      ],
    );
  }
}
