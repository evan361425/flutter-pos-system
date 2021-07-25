import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title_scaffold.dart';
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

    return FadeInTitleScaffold(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(KIcons.back),
      ),
      title: catalog.name,
      trailing: IconButton(
        onPressed: () => showCircularBottomSheet(
          context,
          actions: _actions(context, catalog),
        ),
        icon: Icon(KIcons.more),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(
          Routes.menuProductModal,
          arguments: catalog,
        ),
        tooltip: tt('menu.product.add'),
        child: Icon(KIcons.add),
      ),
      body: _body(catalog, context),
    );
  }

  List<Widget> _actions(BuildContext context, Catalog catalog) {
    return [
      ListTile(
        title: Text(tt('menu.catalog.edit')),
        leading: Icon(Icons.text_fields_sharp),
        onTap: () => Navigator.of(context).pushReplacementNamed(
          Routes.menuCatalogModal,
          arguments: catalog,
        ),
      ),
      ListTile(
        title: Text(tt('menu.product.order')),
        leading: Icon(Icons.reorder_sharp),
        onTap: () => Navigator.of(context).pushReplacementNamed(
            Routes.menuProductReorder,
            arguments: catalog),
      ),
    ];
  }

  Widget _body(Catalog catalog, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(kSpacing3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(catalog.name, style: textTheme.headline4),
              _catalogMetadata(catalog, textTheme),
            ],
          ),
        ),
        Menu.instance.setUpStockMode(context)
            ? catalog.isEmpty
                ? EmptyBody(body: Text(tt('menu.catalog.empty')))
                : ProductList(products: catalog.itemList)
            : CircularLoading(),
      ],
    );
  }

  Widget _catalogMetadata(Catalog catalog, TextTheme textTheme) {
    return RichText(
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
  }
}
