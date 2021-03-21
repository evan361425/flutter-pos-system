import 'package:flutter/material.dart';
import 'package:possystem/components/page/search_scaffold.dart';
import 'package:possystem/models/ingredient_model.dart';
import 'package:possystem/models/stock_model.dart';
import 'package:provider/provider.dart';

class IngredientSearchScaffold extends StatelessWidget {
  const IngredientSearchScaffold({Key key, this.text}) : super(key: key);

  static final String tag = 'menu.poduct.ingredient.search';
  final String text;

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<StockModel>();
    var sortedIngredients = <IngredientModel>[];
    return SearchScaffold<IngredientModel>(
      onChanged: (String text) async {
        sortedIngredients = stock.ingredients.values
            .map<IngredientModel>((e) => e..setSimilarity(text))
            .toList()
              // if ing1 < ing2 return -1 will make ing1 be the first one
              ..sort((ing1, ing2) {
                return ing1.similarity == ing2.similarity
                    ? 0
                    : ing1.similarity < ing2.similarity
                        ? 1
                        : -1;
              });
        return sortedIngredients..sublist(0, 10);
      },
      onLoad: (int index) async {
        return sortedIngredients..sublist(index, index + 10);
      },
      itemBuilder: (context, ingredient) => ListTile(
        title: Text(ingredient.name),
      ),
      emptyBuilder: (context, text) => Center(
        child: Text('找不到「$text」的資訊'),
      ),
      heroTag: IngredientSearchScaffold.tag,
      text: text,
      hintText: '成份名稱，起司',
      textCapitalization: TextCapitalization.words,
    );
  }
}
