import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';

class ProductList extends StatelessWidget {
  final List<ProductModel> products;

  const ProductList({
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<ProductModel>(
      items: products,
      actionBuilder: _actionBuilder,
      tileBuilder: _tileBuilder,
      warningContextBuilder: _warningContextBuilder,
      handleTap: _handleTap,
    );
  }

  Iterable<Widget> _actionBuilder(BuildContext context, ProductModel product) {
    return [
      ListTile(
        title: Text('變更名稱'),
        leading: Icon(Icons.text_fields_sharp),
        onTap: () => Navigator.of(context).pushReplacementNamed(
          MenuRoutes.productModal,
          arguments: product,
        ),
      ),
      ListTile(
        title: Text('排序產品'),
        leading: Icon(Icons.reorder_sharp),
        onTap: () => Navigator.of(context).pushReplacementNamed(
            MenuRoutes.catalogReorder,
            arguments: product.catalog),
      ),
    ];
  }

  void _handleTap(BuildContext context, ProductModel product) {
    Navigator.of(context).pushNamed(
      MenuRoutes.product,
      arguments: product,
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
        emptyText: '尚未設定成份',
      ),
    );
  }

  Widget _warningContextBuilder(BuildContext context, ProductModel product) {
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
}
