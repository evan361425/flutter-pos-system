import 'package:flutter/material.dart';
import 'package:possystem/components/page/slidable_item_list.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    required this.products,
  });

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<ProductModel>(
      items: products,
      onDelete: _onDelete,
      tileBuilder: _tileBuilder,
      warningContext: _warningContextBuild,
      onTap: _onTap,
    );
  }

  Future<void> _onDelete(BuildContext context, ProductModel product) {
    return product.remove();
  }

  Widget _warningContextBuild(BuildContext context, ProductModel product) {
    return RichText(
      text: TextSpan(
        text: '確定要刪除 ',
        children: [
          TextSpan(text: product.name, style: TextStyle(color: kNegativeColor)),
          TextSpan(text: ' 嗎？\n\n'),
          TextSpan(text: '此動作將無法復原！'),
        ],
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  Widget _tileBuilder(BuildContext context, ProductModel product) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(product.name.characters.first.toUpperCase()),
      ),
      title: Text(product.name, style: Theme.of(context).textTheme.headline6),
      subtitle: MetaBlock.withString(
        context,
        product.items.map((e) => e.name),
        '尚未設定成份',
      ),
    );
  }

  void _onTap(BuildContext context, ProductModel product) {
    Navigator.of(context).pushNamed(
      MenuRoutes.product,
      arguments: product,
    );
  }
}
