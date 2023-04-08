import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class MenuSearch extends StatelessWidget {
  static const heroTag = 'menu_search_screen';

  const MenuSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchScaffold<Product>(
      handleChanged: (text) async => Menu.instance.searchProducts(text: text),
      itemBuilder: _itemBuilder,
      emptyBuilder: _emptyBuilder,
      initialData: Menu.instance.searchProducts().toList(),
      hintText: S.menuSearchProductHint,
      textCapitalization: TextCapitalization.words,
      heroTag: heroTag,
    );
  }

  Widget _itemBuilder(BuildContext context, Product item) {
    return CardTile(
      key: Key('search.${item.id}'),
      title: Text(item.name),
      onTap: () => Navigator.of(context).pushReplacementNamed(
        Routes.menuProduct,
        arguments: item..searched(),
      ),
    );
  }

  Widget _emptyBuilder(BuildContext context, String text) {
    return Center(child: Text(S.menuSearchProductNotFound));
  }
}
