import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/widgets/menu_body.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(
          Routes.catalogRoute(CatalogModel.empty()),
        ),
        tooltip: Local.of(context).t('menu.add_catalog'),
      ),
      // When click android go back, it will avoid closing APP
      body: WillPopScope(
        onWillPop: () async => false,
        child: MenuBody(),
      ),
    );
  }
}
