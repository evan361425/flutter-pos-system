import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class MenuProductList extends StatelessWidget {
  final Catalog? catalog;

  const MenuProductList({
    Key? key,
    required this.catalog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableItemList(
      delegate: SlidableItemDelegate<Product, int>(
        groupTag: 'menu.product',
        items: catalog?.itemList ?? Menu.instance.products.toList(),
        deleteValue: 0,
        actionBuilder: _actionBuilder,
        tileBuilder: _tileBuilder,
        warningContextBuilder: _warningContextBuilder,
        handleTap: _handleTap,
        handleDelete: (item) => item.remove(),
      ),
    );
  }

  Iterable<BottomSheetAction<int>> _actionBuilder(Product product) {
    return <BottomSheetAction<int>>[
      BottomSheetAction(
        title: Text(S.menuProductUpdate),
        leading: const Icon(KIcons.modal),
        route: Routes.menuProductModal,
        routePathParameters: {'id': product.id},
      ),
      BottomSheetAction(
        title: Text(S.menuProductReorder),
        leading: const Icon(KIcons.reorder),
        route: Routes.menuCatalogReorder,
        routePathParameters: {'id': product.catalog.id},
      ),
    ];
  }

  void _handleTap(BuildContext context, Product product) {
    context.pushNamed(
      Routes.menuProduct,
      pathParameters: {'id': product.id},
    );
  }

  Widget _tileBuilder(
    BuildContext context,
    int index,
    Product product,
    VoidCallback showActions,
  ) {
    return ListTile(
      key: Key('product.${product.id}'),
      leading: product.avator,
      title: Text(product.name),
      trailing: EntryMoreButton(onPressed: showActions),
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
}
