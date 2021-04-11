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
          onPressed: () => Navigator.of(context).pushNamed(
            MenuRoutes.catalogModal,
          ),
          tooltip: Local.of(context).t('menu.add_catalog'),
          child: Icon(KIcons.add),
        ),
        // When click android go back, it will avoid closing APP
        body: WillPopScope(
          onWillPop: () => showConfirmDialog(context),
          child: MenuBody(),
        ),
      ),
    );
  }

  Future<bool> showConfirmDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('確定要離開 APP 嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('確認'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
