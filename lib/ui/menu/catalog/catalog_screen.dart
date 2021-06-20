import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_list.dart';
import 'package:possystem/ui/menu/menu_routes.dart';
import 'package:provider/provider.dart';

class CatalogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();
    // Logger().d('${catalog.isReady ? 'Edit' : 'Create'} catalog');

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
          useRootNavigator: false,
        ),
        icon: Icon(KIcons.more),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(
          MenuRoutes.productModal,
        ),
        tooltip: Local.of(context)!.t('menu.catalog.add_product'),
        child: Icon(KIcons.add),
      ),
      body: _body(catalog, context),
    );
  }

  List<Widget> _actions(BuildContext context, CatalogModel catalog) {
    return [
      ListTile(
        title: Text('變更名稱'),
        leading: Icon(Icons.text_fields_sharp),
        onTap: () => Navigator.of(context).pushReplacementNamed(
          MenuRoutes.catalogModal,
          arguments: catalog,
        ),
      ),
      ListTile(
        title: Text('排序產品'),
        leading: Icon(Icons.reorder_sharp),
        onTap: () => Navigator.of(context).pushReplacementNamed(
            MenuRoutes.catalogReorder,
            arguments: catalog),
      ),
    ];
  }

  Widget _body(CatalogModel catalog, BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(kSpacing3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _catalogName(catalog, context),
              _catalogMetadata(catalog, context),
            ],
          ),
        ),
        Routes.setUpStockMode(context)
            ? catalog.isEmpty
                ? EmptyBody('menu.catalog.empty_body')
                : ProductList(products: catalog.itemList)
            : CircularLoading(),
      ],
    );
  }

  Widget _catalogMetadata(CatalogModel catalog, BuildContext context) {
    return RichText(
      text: TextSpan(
        text: '產品數量：',
        children: [
          TextSpan(
            text: catalog.length.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          MetaBlock.span(),
          TextSpan(text: catalog.createdDate),
        ],
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  Widget _catalogName(CatalogModel catalog, BuildContext context) {
    return Text(
      catalog.name,
      style: Theme.of(context).textTheme.headline4,
    );
  }
}
