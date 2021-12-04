import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/item_more_action_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/product_slidable_delegate.dart';

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

    final appBar = SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      leading: const PopButton(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(catalog.name),
        background: Image.asset(
          catalog.avator ?? "assets/food_placeholder.png",
          fit: BoxFit.cover,
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          colorBlendMode: BlendMode.srcATop,
        ),
      ),
      actions: const <Widget>[PopButton(toHome: true)],
    );

    final metadata = SliverToBoxAdapter(
      child: ItemMoreActionButton(
        item: Text(S.menuCatalogMetaCreatedAt(catalog.createdAt)),
        onTap: () => _showActions(context, catalog),
      ),
    );

    final aboveData = catalog.isEmpty
        ? SliverToBoxAdapter(
            child: EmptyBody(
                title: S.menuCatalogEmptyBody, onPressed: navigateNewProduct),
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
        appBar,
        metadata,
        aboveData,
        if (catalog.isNotEmpty)
          SliverList(delegate: getProductSlidableDelegate(catalog.itemList)),
      ]),
    );
  }

  void _showActions(BuildContext context, Catalog catalog) async {
    await BottomSheetActions.withDelete(
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
      ],
    );
  }
}

enum _Action {
  delete,
}
