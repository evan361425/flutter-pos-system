import 'package:flutter/material.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/components/empty_body.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/ui/stock/widgets/stock_metadata.dart';
import 'package:provider/provider.dart';

import 'ingredient_list.dart';
import 'stock_batch_actions.dart';

class StockBody extends StatelessWidget {
  const StockBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<StockModel>();
    if (stock.isNotReady) return CircularLoading();
    if (stock.isEmpty) {
      return Center(child: EmptyBody('stock.empty'));
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: StockBatchActions(),
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
