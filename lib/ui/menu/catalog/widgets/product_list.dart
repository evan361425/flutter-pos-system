import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;

  const ProductList({
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return SlidableItemList<Product>(
      items: products,
      actionBuilder: _actionBuilder,
      tileBuilder: _tileBuilder,
      warningContextBuilder: _warningContextBuilder,
      handleTap: _handleTap,
      handleDelete: (_, item) => item.remove(),
    );
  }

  Iterable<BottomSheetAction> _actionBuilder(Product product) {
    return [
      BottomSheetAction(
        title: Text(tt('menu.product.edit')),
        leading: const Icon(Icons.text_fields_sharp),
        onTap: (context) => Navigator.of(context).pushReplacementNamed(
          Routes.menuProductModal,
          arguments: product,
        ),
      ),
      BottomSheetAction(
        title: Text(tt('menu.product.order')),
        leading: const Icon(Icons.reorder_sharp),
        onTap: (context) => Navigator.of(context).pushReplacementNamed(
            Routes.menuProductReorder,
            arguments: product.catalog),
      ),
    ];
  }

  void _handleTap(BuildContext context, Product product) {
    Navigator.of(context).pushNamed(
      Routes.menuProduct,
      arguments: product,
    );
  }

  Widget _tileBuilder(BuildContext context, Product product) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(product.name.characters.first.toUpperCase()),
      ),
      title: Text(product.name, style: Theme.of(context).textTheme.headline6),
      subtitle: MetaBlock.withString(
        context,
        product.items.map((e) => e.name),
        emptyText: tt('menu.ingredient.unset'),
      ),
    );
  }

  Widget _warningContextBuilder(BuildContext context, Product product) {
    return Text(tt('delete_confirm', {'name': product.name}));
  }
}
