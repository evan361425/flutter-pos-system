import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/product_model.dart';
import 'package:provider/provider.dart';

import '../widgets/catalog_modal.dart';
import 'widgets/catalog_body.dart';
import 'widgets/product_modal.dart';
import 'widgets/product_orderable_list.dart';

class CatalogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final catalog = context.read<CatalogModel>();
    // Logger().d('${catalog.isReady ? 'Edit' : 'Create'} catalog');

    return FadeInTitleScaffold(
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.of(context).pop(),
        child: Icon(Icons.arrow_back_ios_sharp),
      ),
      title: catalog.name,
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => showCupertinoModalPopup(
          context: context,
          builder: _moreActions(catalog),
        ),
        child: Icon(Icons.more_horiz_sharp),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) => ProductModal(
            product: ProductModel.empty(),
          ),
        )),
        tooltip: Local.of(context).t('menu.catalog.add_product'),
        child: Icon(Icons.add),
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

  Widget Function(BuildContext) _moreActions(CatalogModel catalog) {
    return (BuildContext context) {
      return CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (_) => CatalogModal(catalog: catalog),
              ),
            ),
            child: Text('變更名稱'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return ProductOrderableList(items: catalog.productList);
                },
              ),
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
