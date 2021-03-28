import 'package:flutter/material.dart';
import 'package:possystem/components/page/item_list.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/product_model.dart';
import 'package:possystem/models/stock_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';

class ProductList extends ItemList<ProductModel> {
  ProductList(List<ProductModel> products, this.stock) : super(products);

  final StockModel stock;

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

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
        context,
        product.ingredients.keys.map((id) => stock[id]?.name),
        '尚未設定成份',
      ),
      onTap: () {
        if (shouldProcess()) {
          Navigator.of(context).pushNamed(
            MenuRoutes.routeProduct,
            arguments: product,
          );
        }
      },
    );
  }
}
