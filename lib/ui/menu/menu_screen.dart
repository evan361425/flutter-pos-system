import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/widgets/menu_actions.dart';

import 'widgets/menu_body.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('主頁'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => showCupertinoModalPopup(
            context: context,
            builder: (_) => MenuActions(),
          ),
          child: Icon(Icons.more_horiz_sharp),
        ),
      ),
      child: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(
          Routes.catalogModal,
          arguments: CatalogModel.empty(),
        ),
        tooltip: Local.of(context).t('menu.add_catalog'),
        child: Icon(Icons.add),
      ),
      // When click android go back, it will avoid closing APP
      body: WillPopScope(
        onWillPop: () async => false,
        child: MenuBody(),
      ),
    );
  }
}
