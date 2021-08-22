import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/widgets/ingredient_modal.dart';
import 'package:provider/provider.dart';

class ProductIngredientSearch extends StatelessWidget {
  final String? text;

  const ProductIngredientSearch({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<Stock>();

    return SearchScaffold<Ingredient>(
      handleChanged: (text) async => stock.sortBySimilarity(text),
      itemBuilder: _itemBuilder,
      emptyBuilder: _emptyBuilder,
      initialData: stock.itemList,
      text: text ?? '',
      hintText: tt('menu.ingredient.label.name'),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _itemBuilder(BuildContext context, Ingredient ingredient) {
    return CardTile(
      title: Text(ingredient.name),
      trailing: IconButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => IngredientModal(
                  ingredient: ingredient,
                  editable: false,
                ))),
        icon: Icon(Icons.open_in_new_sharp),
      ),
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
