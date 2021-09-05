import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title_scaffold.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/item_editable_info.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_list.dart';
import 'package:provider/provider.dart';

class CatalogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<Catalog>();
    // if change ingredient in product_ingredient_search
    context.watch<Stock>();

    final navigateNewProduct = () => Navigator.of(context).pushNamed(
          Routes.menuProductModal,
          arguments: catalog,
        );

    return FadeInTitleScaffold(
      leading: PopButton(),
      title: catalog.name,
      trailing: PopButton(toHome: true),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateNewProduct,
        tooltip: tt('menu.product.add'),
        child: Icon(KIcons.add),
      ),
      body: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(kSpacing3),
          child: ItemEditableInfo(
            item: catalog,
            metadata: _CatalogMetadata(catalog),
            onEdit: () => _showActions(context, catalog),
          ),
        ),
        catalog.isEmpty
            ? EmptyBody(title: '可以新增產品囉！', onPressed: navigateNewProduct)
            : ProductList(products: catalog.itemList),
      ]),
    );
  }

  void _showActions(BuildContext context, Catalog catalog) async {
    await BottomSheetActions.withDelete(
      context,
      deleteCallback: catalog.remove,
      deleteValue: _Action.delete,
      popAfterDeleted: true,
      warningContent: Text(tt('delete_confirm', {'name': catalog.name})),
      actions: <BottomSheetAction<_Action>>[
        BottomSheetAction(
          title: Text(tt('menu.catalog.edit')),
          leading: Icon(Icons.text_fields_sharp),
          navigateArgument: catalog,
          navigateRoute: Routes.menuCatalogModal,
        ),
        BottomSheetAction(
          title: Text(tt('menu.product.order')),
          leading: Icon(Icons.reorder_sharp),
          navigateArgument: catalog,
          navigateRoute: Routes.menuProductReorder,
        ),
      ],
    );
  }
}

class _CatalogMetadata extends StatelessWidget {
  final Catalog catalog;

  const _CatalogMetadata(this.catalog);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyText1,
        text: tt('menu.product.count'),
        children: [
          TextSpan(
            text: catalog.length.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          MetaBlock.span(),
          TextSpan(text: catalog.createdDate),
        ],
      ),
    );
  }
}

enum _Action {
  delete,
}
