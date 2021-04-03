import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/menu_routes.dart';
import 'package:provider/provider.dart';

import 'widgets/catalog_body.dart';

class CatalogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final catalog = context.read<CatalogModel>();
    // Logger().d('${catalog.isReady ? 'Edit' : 'Create'} catalog');

    return FadeInTitleScaffold(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(KIcons.back),
      ),
      title: catalog.name,
      trailing: IconButton(
        onPressed: () => showCupertinoModalPopup(
          context: context,
          builder: _moreActions(catalog),
          useRootNavigator: false,
        ),
        icon: Icon(KIcons.more),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(
          MenuRoutes.routeProductModal,
        ),
        tooltip: Local.of(context).t('menu.catalog.add_product'),
        child: Icon(KIcons.add),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final catalog = context.watch<CatalogModel>();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _catalogName(catalog, context),
              _catalogMetadata(catalog, context),
            ],
          ),
        ),
        CatalogBody(),
      ],
    );
  }

  Widget _catalogMetadata(CatalogModel catalog, BuildContext context) {
    if (!catalog.isReady) return null;

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

  WidgetBuilder _moreActions(CatalogModel catalog) {
    return (BuildContext context) {
      return CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context)
                .pushReplacementNamed(Routes.catalogModal, arguments: catalog),
            child: Text('變更名稱'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pushReplacementNamed(
              MenuRoutes.routeProductOrder,
            ),
            child: Text('排序產品'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: Text('取消'),
        ),
      );
    };
  }
}
