import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title_scaffold.dart';
import 'package:possystem/components/style/item_editable_info.dart';
import 'package:possystem/components/style/nav_home_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_list.dart';
import 'package:provider/provider.dart';

class CatalogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<Catalog>();

    final textTheme = Theme.of(context).textTheme;

    final navigateNewProduct = () => Navigator.of(context).pushNamed(
          Routes.menuProductModal,
          arguments: catalog,
        );

    final metadata = RichText(
      text: TextSpan(
        text: tt('menu.product.count'),
        children: [
          TextSpan(
            text: catalog.length.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          MetaBlock.span(),
          TextSpan(text: catalog.createdDate),
        ],
        style: textTheme.bodyText1,
      ),
    );

    final body = Menu.instance.setUpStockMode(context)
        ? catalog.isEmpty
            ? EmptyBody(title: '可以新增產品囉！', onPressed: navigateNewProduct)
            : ProductList(products: catalog.itemList)
        : CircularLoading();

    return FadeInTitleScaffold(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(KIcons.back),
      ),
      title: catalog.name,
      trailing: NavHomeButton(),
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
            metadata: metadata,
            onEdit: () => showCircularBottomSheet(
              context,
              actions: _actions(catalog),
            ),
          ),
        ),
        body,
      ]),
    );
  }

  List<BottomSheetAction> _actions(Catalog catalog) {
    return <BottomSheetAction>[
      BottomSheetAction(
        title: Text(tt('menu.catalog.edit')),
        leading: Icon(Icons.text_fields_sharp),
        onTap: (context) => Navigator.of(context).pushReplacementNamed(
          Routes.menuCatalogModal,
          arguments: catalog,
        ),
      ),
      BottomSheetAction(
        title: Text(tt('menu.product.order')),
        leading: Icon(Icons.reorder_sharp),
        onTap: (context) => Navigator.of(context).pushReplacementNamed(
            Routes.menuProductReorder,
            arguments: catalog),
      ),
    ];
  }
}
