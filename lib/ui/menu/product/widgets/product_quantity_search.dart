import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/translator.dart';

class ProductQuantitySearch extends StatelessWidget {
  ProductQuantitySearch({Key? key, this.text}) : super(key: key);

  static final String tag = 'menu.poduct.quantity.search';
  final String? text;
  final scaffold = GlobalKey<SearchScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SearchScaffold<QuantityModel>(
      key: scaffold,
      handleChanged: (String text) async =>
          QuantityRepo.instance.sortBySimilarity(text),
      itemBuilder: _itemBuilder,
      emptyBuilder: _emptyBuilder,
      initialData: () async => QuantityRepo.instance.itemList,
      text: text ?? '',
      hintText: tt('menu.quantity.label.name'),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _itemBuilder(BuildContext context, dynamic ingredient) {
    return CardTile(
      title: Text(ingredient.name),
      onTap: () {
        Navigator.of(context).pop<QuantityModel>(ingredient);
      },
    );
  }

  Widget _emptyBuilder(BuildContext context, String text) {
    return CardTile(
      title: Text(tt('menu.quantity.add_quantity', {'name': text})),
      onTap: () async {
        final quantity = QuantityModel(name: text);
        await QuantityRepo.instance.setItem(quantity);
        Navigator.of(context).pop<QuantityModel>(quantity);
      },
    );
  }
}
