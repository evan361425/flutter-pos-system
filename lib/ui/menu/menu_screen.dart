import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/models.dart';
import 'package:possystem/ui/menu/widgets/catalog_name_modal.dart';
import 'package:possystem/ui/menu/widgets/catalog_orderable_list.dart';
import 'package:provider/provider.dart';

import 'widgets/menu_body.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('主頁'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(Icons.more_horiz_sharp),
          onPressed: () => showCupertinoModalPopup(
            context: context,
            builder: _moreActions,
          ),
        ),
      ),
      child: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) => CatalogNameModal(),
        )),
        tooltip: Local.of(context).t('menu.add_catalog'),
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
          child: Text('排序產品種類'),
          onPressed: () => Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (BuildContext context) {
                final items = context.watch<MenuModel>().catalogList;
                return CatalogOrderableList(items: items);
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
  }
}