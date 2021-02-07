import 'package:flutter/material.dart';
import 'package:possystem/components/backend/page.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/components/backend/appbar.dart';
import 'package:possystem/components/backend/bottom_navbar.dart';

class StockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackendAppBar(context, Local.of(context).t('stock')),
      bottomNavigationBar: BackendBottomNavBar(BackendBottomNavs.stock),
      body: BackendPage(
        child: Center(
          child: Text(
            'Stock',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
