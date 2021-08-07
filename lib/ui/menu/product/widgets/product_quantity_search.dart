import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/translator.dart';

class ProductQuantitySearch extends StatelessWidget {
  final String? text;

  const ProductQuantitySearch({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchScaffold<Quantity>(
      handleChanged: (text) async => Quantities.instance.sortBySimilarity(text),
      itemBuilder: _itemBuilder,
      emptyBuilder: _emptyBuilder,
      initialData: Quantities.instance.itemList,
      text: text ?? '',
      hintText: tt('menu.quantity.label.name'),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _itemBuilder(BuildContext context, Quantity quantity) {
    return CardTile(
      title: Text(quantity.name),
      onTap: () {
        Navigator.of(context).pop<Quantity>(quantity);
      },
    );
  }

  Widget _emptyBuilder(BuildContext context, String text) {
    return CardTile(
      title: Text(tt('menu.quantity.add_quantity', {'name': text})),
      onTap: () async {
        final quantity = Quantity(name: text);
        await Quantities.instance.setItem(quantity);
        Navigator.of(context).pop<Quantity>(quantity);
      },
    );
  }
}
