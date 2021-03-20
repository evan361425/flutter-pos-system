import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/ui/menu/menu_routes.dart';

import 'widgets/catalog_name_modal.dart';
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
            builder: _moreActions,
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
        onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) => CatalogNameModal(),
        )),
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

  Widget _moreActions(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pushReplacement(
            MenuRoutes.reorderCatalog(),
          ),
          child: Text('排序產品種類'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context, 'cancel'),
        child: Text('取消'),
      ),
    );
  }
}
