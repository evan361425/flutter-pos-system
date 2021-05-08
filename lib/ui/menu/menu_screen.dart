import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/ui/menu/widgets/catalog_modal.dart';
import 'package:possystem/ui/menu/widgets/menu_actions.dart';
import 'package:provider/provider.dart';

import 'widgets/menu_body.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuModel>();
    if (menu.isNotReady) return CircularLoading();

    return Scaffold(
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
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CatalogModal()),
        ),
        tooltip: Local.of(context).t('menu.add_catalog'),
        child: Icon(KIcons.add),
      ),
      // When click android go back, it will avoid closing APP
      body: MenuBody(),
    );
  }
}
