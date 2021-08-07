import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/search_scaffold.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';

class MenuSearch extends StatelessWidget {
  const MenuSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchScaffold<Product>(
      handleChanged: (text) async => Menu.instance.searchProducts(text: text),
      itemBuilder: _itemBuilder,
      emptyBuilder: _emptyBuilder,
      initialData: Menu.instance.searchProducts().toList(),
      hintText: '搜尋產品、成份、份量',
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _itemBuilder(BuildContext context, Product item) {
    return CardTile(
      title: Text(item.name),
      onTap: () => Navigator.of(context).pushNamed(
        Routes.menuProduct,
        arguments: item,
      ),
    );
  }

  Widget _emptyBuilder(BuildContext context, String text) {
    return Center(child: Text('搜尋不到相關資訊，打錯字了嗎？'));
  }
}
