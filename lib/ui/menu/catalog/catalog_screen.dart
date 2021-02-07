import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/ui/menu/catalog/widgets/catalog_body.dart';
import 'package:possystem/ui/menu/catalog/widgets/catalog_metadata.dart';
import 'package:possystem/ui/menu/catalog/widgets/catalog_name.dart';
import 'package:possystem/ui/menu/catalog_navigator.dart';
import 'package:provider/provider.dart';

class CatalogScreen extends StatelessWidget {
  final scaffold = GlobalKey<ScaffoldState>();
  final void Function() popRoot;

  CatalogScreen({this.popRoot});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();

    return Scaffold(
      key: scaffold,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: popRoot,
        ),
        title: Text(Local.of(context).t('menu.catalog.title')),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: catalog.isReady
            ? () => Navigator.of(context).pushNamed(
                  CatalogRoutes.product,
                )
            : () => scaffold.currentState.showSnackBar(SnackBar(
                  content: Text('menu.catalog.error.add'),
                )),
        tooltip: Local.of(context).t('menu.catalog.add_product'),
      ),
      body: Container(
        padding: EdgeInsets.only(top: defaultPadding),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                children: [
                  CatalogName(),
                  CatalogMetadata(),
                ],
              ),
            ),
            Expanded(child: CatalogBody()),
          ],
        ),
      ),
    );
  }
}
