import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/ui/stock/stock_routes.dart';

import 'widgets/stock_body.dart';

class StockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('庫存'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(
                StockRoutes.routeQuantity,
              ),
              child: Text('設定份量'),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed(
            StockRoutes.routeIngredient,
          ),
          tooltip: '新增成份',
          child: Icon(KIcons.add),
        ),
        body: StockBody(),
      ),
    );
  }
}
