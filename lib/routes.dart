import 'package:flutter/material.dart';
import 'package:possystem/ui/order/order_screen.dart';

import 'ui/menu/catalog_navigator.dart';
import 'ui/stock/ingredient/ingredient_screen.dart';
import 'ui/stock/quantity/quantity_screen.dart';
import 'ui/stock/quantity/widgets/quantity_modal.dart';
import 'ui/stock/stock_batch/stock_batch_modal.dart';

class Routes {
  static final String order = 'order';
  static final String menuCatalog = 'menu/catalog';
  static const String stockBatchModal = 'stcok/batch/modal';
  static const String stockQuantity = 'stcok/quantity';
  static const String stockIngredient = 'stcok/ingredient';
  static const String stockQuantityModal = 'stcok/quantity/modal';

  static final routes = <String, WidgetBuilder>{
    order: (context) => OrderScreen(),
    menuCatalog: (context) => CatalogNavigator(
          catalog: ModalRoute.of(context).settings.arguments,
        ),
    stockIngredient: (context) => IngredientScreen(
          ingredient: ModalRoute.of(context).settings.arguments,
        ),
    stockQuantity: (_) => QuantityScreen(),
    stockQuantityModal: (context) => QuantityModal(
          quantity: ModalRoute.of(context).settings.arguments,
        ),
    stockBatchModal: (context) => StockBatchModal(
          batch: ModalRoute.of(context).settings.arguments,
        ),
  };
}
