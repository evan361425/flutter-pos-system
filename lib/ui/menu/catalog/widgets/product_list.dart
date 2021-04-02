import 'package:flutter/material.dart';
import 'package:possystem/components/page/slidable_item_list.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/product_model.dart';
import 'package:possystem/models/stock_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    @required this.products,
    @required this.stock,
  });

  final List<ProductModel> products;
  final StockModel stock;

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<ProductModel>(
      items: products,
      onDelete: onDelete,
      tileBuilder: tileBuilder,
      warningContext: warningContextBuild,
      onTap: onTap,
    );
  }

  void onDelete(context, product) {
    final catalog = context.read<CatalogModel>();
    catalog.removeProduct(product.id);
  }

  Widget warningContextBuild(BuildContext context, ProductModel product) {
    return RichText(
      text: TextSpan(text: '確定要刪除', children: [
        TextSpan(text: product.name, style: TextStyle(color: kNegativeColor)),
        TextSpan(text: '嗎？\n'),
        TextSpan(text: '此動作將無法復原'),
      ]),
    );
  }

  Widget tileBuilder(BuildContext context, ProductModel product) {
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
    );
  }

  void onTap(BuildContext context, ProductModel product) {
    Navigator.of(context).pushNamed(
      MenuRoutes.routeProduct,
      arguments: product,
    );
  }
}
