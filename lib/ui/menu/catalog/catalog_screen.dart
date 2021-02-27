import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/fade_in_title.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/widgets/catalog_body.dart';
import 'package:provider/provider.dart';

class CatalogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CatalogModel catalog = ModalRoute.of(context).settings.arguments;
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
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: catalog.isReady
              ? () => Navigator.of(context).pushNamed(Routes.product)
              : () => Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('menu.catalog.error.add'),
                    ),
                  ),
          tooltip: Local.of(context).t('menu.catalog.add_product'),
        ),
        body: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final catalog = context.watch<CatalogModel>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
    if (!catalog.isReady || catalog.length == 0) return null;

    return RichText(
      text: TextSpan(
        text: '產品數量：',
        children: [
          TextSpan(
            text: catalog.length.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}
