import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

SliverSlidableItemBuilder getProductSlidableDelegate(List<Product> products) {
  return SliverSlidableItemBuilder(SlidableItemDelegate<Product, int>(
    items: products,
    deleteValue: 0,
    actionBuilder: _actionBuilder,
    tileBuilder: _tileBuilder,
    warningContextBuilder: _warningContextBuilder,
    handleTap: _handleTap,
    handleDelete: (item) => item.remove(),
  ));
}

Iterable<BottomSheetAction<int>> _actionBuilder(Product product) {
  return <BottomSheetAction<int>>[
    BottomSheetAction(
      title: Text(S.menuProductUpdate),
      leading: const Icon(Icons.text_fields_sharp),
      navigateRoute: Routes.menuProductModal,
      navigateArgument: product,
    ),
    BottomSheetAction(
      title: Text(S.menuProductReorder),
      leading: const Icon(Icons.reorder_sharp),
      navigateRoute: Routes.menuProductReorder,
      navigateArgument: product.catalog,
    ),
  ];
}

void _handleTap(BuildContext context, Product product) {
  Navigator.of(context).pushNamed(
    Routes.menuProduct,
    arguments: product,
  );
}

Widget _tileBuilder(BuildContext context, int index, Product product, _) {
  return ListTile(
    key: Key('product.${product.id}'),
    leading: CircleAvatar(
      child: Text(product.name.characters.first.toUpperCase()),
    ),
    title: Text(product.name),
    subtitle: MetaBlock.withString(
      context,
      product.items.map((e) => e.name),
      emptyText: S.menuProductListEmptyIngredient,
    ),
  );
}

Widget _warningContextBuilder(BuildContext context, Product product) {
  return Text(S.dialogDeletionContent(product.name, ''));
}
