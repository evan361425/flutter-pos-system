import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/ui/menu/menu_routes.dart';
import 'package:possystem/ui/menu/widgets/menu_actions.dart';

import 'widgets/menu_body.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('主頁'),
          actions: [
            IconButton(
              onPressed: () => showCupertinoModalPopup(
                context: context,
                builder: (_) => MenuActions(),
              ),
              icon: Icon(KIcons.more),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: MenuRoutes.getBuilder(
              RouteSettings(name: MenuRoutes.routeCatalogModal),
            ),
          )),
          tooltip: Local.of(context).t('menu.add_catalog'),
          child: Icon(KIcons.add),
        ),
        // When click android go back, it will avoid closing APP
        body: WillPopScope(
          onWillPop: () async => false,
          child: MenuBody(),
        ),
      ),
    );
  }
}
