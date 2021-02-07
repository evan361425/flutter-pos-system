import 'package:flutter/material.dart';
import 'package:possystem/components/backend/appbar.dart';
import 'package:possystem/components/backend/bottom_navbar.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/widgets/menu_body.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackendAppBar(context, Local.of(context).t('menu')),
      bottomNavigationBar: BackendBottomNavBar(BackendBottomNavs.menu),
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
