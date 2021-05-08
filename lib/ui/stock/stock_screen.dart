import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/home_container.dart';
import 'package:provider/provider.dart';

import 'widgets/stock_body.dart';

class StockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: StockBatchRepo.instance,
      child: SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.stockIngredient,
            ),
            tooltip: '新增成份',
            child: Icon(KIcons.add),
          ),
          body: WillPopScope(
            onWillPop: () async {
              HomeContainer.tabController.index = 0;
              return false;
            },
            child: StockBody(),
          ),
        ),
      ),
    );
  }
}
