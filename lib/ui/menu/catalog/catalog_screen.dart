import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/models.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_modal.dart';
import 'package:possystem/ui/menu/widgets/catalog_name_modal.dart';
import 'package:provider/provider.dart';

import 'widgets/catalog_body.dart';
import 'widgets/product_orderable_list.dart';

class CatalogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CatalogModel catalog =
        ModalRoute.of(context).settings.arguments ?? CatalogModel.empty();
    // Logger().d('${catalog.isReady ? 'Edit' : 'Create'} catalog');

    return ChangeNotifierProvider<CatalogModel>.value(
      value: catalog,
      builder: (BuildContext context, _) => FadeInTitleScaffold(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(Icons.arrow_back_ios_sharp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: catalog.name,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(Icons.more_horiz_sharp),
          onPressed: () => showCupertinoModalPopup(
            context: context,
            builder: _moreActions(catalog),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => ProductModal(
              product: ProductModel.empty(catalog),
            ),
          )),
          tooltip: Local.of(context).t('menu.catalog.add_product'),
        ),
        body: _body(context),
      ),
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

  Widget _catalogName(CatalogModel catalog, BuildContext context) {
    return Text(
      catalog.name,
      style: Theme.of(context).textTheme.headline4,
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

  Widget Function(BuildContext) _moreActions(CatalogModel catalog) {
    return (BuildContext context) {
      return CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('變更名稱'),
            onPressed: () => Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (_) => CatalogNameModal(oldName: catalog.name),
              ),
            ),
          ),
          CupertinoActionSheetAction(
            child: Text('排序產品'),
            onPressed: () => Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return ProductOrderableList(items: catalog.productList);
                },
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('取消'),
          onPressed: () => Navigator.pop(context, 'cancel'),
        ),
      );
    };
  }
}
