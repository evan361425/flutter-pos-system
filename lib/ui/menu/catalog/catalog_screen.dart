import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slivers/sliver_image_app_bar.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/item_more_action_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/product_slidable_list.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<Catalog>();
    // if change ingredient in product_ingredient_search
    context.watch<Stock>();

    navigateNewProduct() => Navigator.of(context).pushNamed(
          Routes.menuProductModal,
          arguments: catalog,
        );

    final metadata = SliverToBoxAdapter(
      child: ItemMoreActionButton(
        item: MetaBlock.withString(context, [
          S.menuCatalogMetaTitle,
          S.menuCatalogMetaCreatedAt(catalog.createdAt),
        ])!,
        onTap: () => _showActions(context, catalog),
      ),
    );

    final aboveData = catalog.isEmpty
        ? SliverToBoxAdapter(
            child: EmptyBody(
              title: S.menuCatalogEmptyBody,
              tooltip: '「產品」是菜單裡的基本單位，你可以在產品中設定成分等資訊。\n'
                  '例如：\n'
                  '「起司漢堡」有「起司」、「麵包」等成分',
              onPressed: navigateNewProduct,
            ),
          )
        : SliverToBoxAdapter(
            child: Center(child: HintText(S.totalCount(catalog.length))),
          );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        key: const Key('catalog.add'),
        onPressed: navigateNewProduct,
        tooltip: S.menuProductCreate,
        child: const Icon(KIcons.add),
      ),
      body: CustomScrollView(slivers: [
        SliverImageAppBar(model: catalog),
        metadata,
        aboveData,
        if (catalog.isNotEmpty) ProductSlidableList(catalog: catalog),
      ]),
    );
  }

  void _showActions(BuildContext context, Catalog catalog) async {
    final result = await BottomSheetActions.withDelete(
      context,
      deleteCallback: catalog.remove,
      deleteValue: _Action.delete,
      popAfterDeleted: true,
      warningContent: Text(S.dialogDeletionContent(catalog.name, '')),
      actions: <BottomSheetAction<_Action>>[
        BottomSheetAction(
          title: Text(S.menuCatalogUpdate),
          leading: const Icon(Icons.text_fields_sharp),
          navigateArgument: catalog,
          navigateRoute: Routes.menuCatalogModal,
        ),
        BottomSheetAction(
          title: Text(S.menuProductReorder),
          leading: const Icon(Icons.reorder_sharp),
          navigateArgument: catalog,
          navigateRoute: Routes.menuProductReorder,
        ),
        const BottomSheetAction(
          title: Text('更新照片'),
          leading: Icon(Icons.image_sharp),
          returnValue: _Action.changeImage,
        ),
      ],
    );

    if (result == _Action.changeImage && context.mounted) {
      await catalog.pickImage(context);
    }
  }
}

enum _Action {
  delete,
  changeImage,
}
