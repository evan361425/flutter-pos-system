import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog_navigator.dart';
import 'package:possystem/ui/menu/menu_screen.dart';

class MenuTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      routes: {
        Routes.catalog: (BuildContext context) => CatalogNavigator(),
      },
      // When click android go back, it will avoid closing APP
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('主頁'),
            trailing: Material(
              child: FlatButton(
                // visualDensity: VisualDensity(horizontal: -4),
                child: Text('點餐'),
                onPressed: () {},
              ),
            ),
          ),
          child: SafeArea(child: MenuScreen()),
        );
      },
    );
  }
}
