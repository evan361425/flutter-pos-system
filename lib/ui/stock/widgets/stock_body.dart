import 'package:flutter/material.dart';
import 'package:possystem/models/stock_model.dart';
import 'package:possystem/ui/stock/widgets/stock_metadata.dart';
import 'package:provider/provider.dart';

import 'ingredient_list.dart';
import 'stock_batch_update_button.dart';

class StockBody extends StatelessWidget {
  const StockBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<StockModel>();
    if (stock.isNotReady) return CircularProgressIndicator();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: StockUpdateMultipleButton(),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StockMetadata(),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: IngredientList(ingredients: stock.ingredientList),
        ),
      ),
    ]);
  }
}
