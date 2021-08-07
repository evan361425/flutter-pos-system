import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';

class ProductIngredientSearch extends StatelessWidget {
  final String? text;

  const ProductIngredientSearch({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchScaffold<Ingredient>(
      handleChanged: (text) async => Stock.instance.sortBySimilarity(text),
      itemBuilder: _itemBuilder,
      emptyBuilder: _emptyBuilder,
      initialData: Stock.instance.itemList,
      text: text ?? '',
      hintText: tt('menu.ingredient.label.name'),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _itemBuilder(BuildContext context, Ingredient ingredient) {
    return CardTile(
      title: Text(ingredient.name),
      onTap: () {
        Navigator.of(context).pop<Ingredient>(ingredient);
      },
    );
  }

  Widget _emptyBuilder(BuildContext context, String text) {
    return CardTile(
      title: Text(tt('menu.ingredient.add_ingredient', {'name': text})),
      onTap: () async {
        final ingredient = Ingredient(name: text);
        await Stock.instance.setItem(ingredient);
        Navigator.of(context).pop<Ingredient>(ingredient);
      },
    );
  }
}
