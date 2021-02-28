import 'package:flutter/material.dart';
import 'package:possystem/components/item_list.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/product_model.dart';
import 'package:possystem/routes.dart';

class ProductList extends ItemList<ProductModel> {
  ProductList(List<ProductModel> products) : super(products);

  @override
  void onDelete(ProductModel product) {
    print('Deletet');
  }

  @override
  Widget itemTile(BuildContext context, ProductModel product) {
    return ListTile(
      leading: CircleAvatar(child: Text(product.name[0])),
      title: Text(product.name, style: Theme.of(context).textTheme.headline6),
      subtitle: _ingredientList(product),
      onTap: () {
        if (shouldProcess()) {
          Navigator.of(context).pushNamed(
            Routes.product,
            arguments: product,
          );
        }
      },
    );
  }

  Widget _ingredientList(ProductModel product) {
    final children = <Widget>[];
    product.ingredients.values.forEach((ingredient) {
      children.add(Text(ingredient.name));
      children.add(MetaBlock());
    });

    if (children.isNotEmpty) {
      children.removeLast();
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: children,
      );
    }

    return null;
  }
}
