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
      withFAB: true,
      delegate: SlidableItemDelegate<Product, int>(
        items: catalog?.itemList ?? Menu.instance.products.toList(),
        deleteValue: 0,
        actionBuilder: _actionBuilder,
        tileBuilder: _tileBuilder,
        confirmContextBuilder: _confirmContextBuilder,
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
      leading: product.avator,
      title: Text(product.name),
      trailing: EntryMoreButton(onPressed: showActions),
      subtitle: MetaBlock.withString(
        context,
        product.items.map((e) => e.name),
        emptyText: S.menuProductListEmptyIngredient,
      ),
      onLongPress: showActions,
      onTap: () => context.pushNamed(
        Routes.menuProduct,
        pathParameters: {'id': product.id},
      ),
    );
  }

  Widget _confirmContextBuilder(BuildContext context, Product product) {
    return Text(S.dialogDeletionContent(product.name, ''));
  }
}
