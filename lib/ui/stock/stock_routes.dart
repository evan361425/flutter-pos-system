import 'package:flutter/material.dart';
import 'package:possystem/ui/stock/stock_screen.dart';

import 'ingredient/ingredient_screen.dart';
import 'quantity/quantity_screen.dart';
import 'stock_batch/stock_batch_modal.dart';

class StockRoutes {
  static const String routeBatchModal = 'batch/modal';
  static const String routeQuantity = 'quantity';
  static const String routeIngredient = 'ingredient';

  static WidgetBuilder getBuilder(RouteSettings settings) {
    switch (settings.name) {
      case routeIngredient:
        return (_) => IngredientScreen(ingredient: settings.arguments);
      case routeQuantity:
        return (_) => QuantityScreen();
      case routeBatchModal:
        return (_) => StockBatchModal(batch: settings.arguments);
      default:
        return (_) => WillPopScope(
              onWillPop: () async => false,
              child: StockScreen(),
            );
    }
  }
}
