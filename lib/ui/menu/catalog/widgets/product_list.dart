import 'package:flutter/material.dart';
import 'package:possystem/components/item_list.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/product_model.dart';
import 'package:possystem/ui/menu/catalog_navigator.dart';

class ProductList extends ItemList<ProductModel> {
  ProductList(List<ProductModel> products) : super(products);

  @override
  void onDelete(ProductModel product) {
    print('Deletet');
  }

  @override
  Widget itemTile(BuildContext context, ProductModel product) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          product.enable
              ? Icon(Icons.check_circle, color: colorPositive)
              : Icon(Icons.remove_circle, color: colorWarning),
        ],
      ),
      title: Text(product.name, style: Theme.of(context).textTheme.headline6),
      subtitle: Text('ham, bread, fish, ...'),
      onTap: () {
        if (shouldProcess()) {
          Navigator.of(context).pushNamed(
            CatalogRoutes.product,
            arguments: product,
          );
        }
      },
    );
  }
}
