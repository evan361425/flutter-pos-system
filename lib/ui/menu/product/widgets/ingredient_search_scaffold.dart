import 'package:flutter/material.dart';
import 'package:possystem/components/card_tile.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/repository/stock_model.dart';

class IngredientSearchScaffold extends StatelessWidget {
  IngredientSearchScaffold({Key? key, this.text}) : super(key: key);

  static final String tag = 'menu.poduct.ingredient.search';
  final String? text;
  final scaffold = GlobalKey<SearchScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SearchScaffold<IngredientModel>(
      key: scaffold,
      onChanged: (String text) async =>
          StockModel.instance.sortBySimilarity(text),
      itemBuilder: _itemBuilder,
      emptyBuilder: _emptyBuilder,
      initialData: () async => StockModel.instance.ingredientList,
      heroTag: IngredientSearchScaffold.tag,
      text: text ?? '',
      hintText: '成份名稱，起司',
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _itemBuilder(BuildContext context, dynamic ingredient) {
    return CardTile(
      title: Text(ingredient.name),
      onTap: () {
        Navigator.of(context).pop<IngredientModel>(ingredient);
      },
    );
  }

  Widget _emptyBuilder(BuildContext context, String text) {
    return CardTile(
      title: Text('新增成份「$text」'),
      onTap: () {
        final ingredient = IngredientModel(name: text);
        StockModel.instance.setIngredient(ingredient);
        Navigator.of(context).pop<IngredientModel>(ingredient);
      },
    );
  }
}
