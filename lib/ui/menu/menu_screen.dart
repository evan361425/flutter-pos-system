import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/routes.dart';

import 'widgets/menu_body.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('主頁'),
        trailing: CupertinoButton(
          onPressed: () {
            print('go order');
          },
          child: Icon(Icons.shopping_bag_sharp),
          padding: EdgeInsets.zero,
        ),
      ),
      child: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed(Routes.catalog),
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
