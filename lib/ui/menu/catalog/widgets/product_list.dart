import 'package:flutter/material.dart';
import 'package:possystem/components/item_list.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/product_model.dart';
import 'package:possystem/ui/menu/navigators/catalog_navigator.dart';
import 'package:provider/provider.dart';

class ProductList extends ItemList<ProductModel> {
  ProductList(List<ProductModel> products) : super(products);

  @override
  void onDelete(ProductModel product) {
    print('Deletet');
  }

  @override
  Widget itemTile(BuildContext context, ProductModel product) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(product.name.characters.first.toUpperCase()),
      ),
      title: Text(product.name, style: Theme.of(context).textTheme.headline6),
      subtitle: MetaBlock.withString(
        product.ingredients.keys,
        context,
      ),
      onTap: () {
        if (shouldProcess()) {
          context.read<CatalogNavigatorState>().product = product;
        }
      },
    );
  }
}
