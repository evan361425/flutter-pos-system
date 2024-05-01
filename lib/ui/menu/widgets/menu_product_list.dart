import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class MenuProductList extends StatelessWidget {
  final Catalog? catalog;

  const MenuProductList({
    super.key,
    required this.catalog,
  });

  @override
  Widget build(BuildContext context) {
    return SlidableItemList(
      delegate: SlidableItemDelegate<Product, int>(
        items: catalog?.itemList ?? Menu.instance.products.toList(),
        deleteValue: 0,
        actionBuilder: _actionBuilder,
        tileBuilder: _tileBuilder,
        warningContentBuilder: _warningContentBuilder,
        handleDelete: (item) => item.remove(),
      ),
    );
  }

  Iterable<BottomSheetAction<int>> _actionBuilder(Product product) {
    return <BottomSheetAction<int>>[
      BottomSheetAction(
        title: Text(S.menuProductTitleUpdate),
        leading: const Icon(KIcons.modal),
        route: Routes.menuProductModal,
        routePathParameters: {'id': product.id},
      ),
    ];
  }

  Widget _tileBuilder(
    BuildContext context,
    Product product,
    int index,
    VoidCallback showActions,
  ) {
    return ListTile(
      key: Key('product.${product.id}'),
      leading: product.useDefaultImage ? product.avator : Hero(tag: product, child: product.avator),
      title: Text(product.name),
      trailing: EntryMoreButton(onPressed: showActions),
      subtitle: MetaBlock.withString(
        context,
        product.items.map((e) => e.name),
        emptyText: S.menuProductEmptyIngredients,
      ),
      onLongPress: showActions,
      onTap: () => context.pushNamed(
        Routes.menuProduct,
        pathParameters: {'id': product.id},
      ),
    );
  }

  Widget _warningContentBuilder(BuildContext context, Product product) {
    return Text(S.dialogDeletionContent(product.name, ''));
  }
}
