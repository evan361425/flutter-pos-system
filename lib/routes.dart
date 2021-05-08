import 'package:flutter/material.dart';
import 'package:possystem/ui/order/order_screen.dart';
import 'package:provider/provider.dart';

import 'components/circular_loading.dart';
import 'models/repository/menu_model.dart';
import 'models/repository/quantity_repo.dart';
import 'models/repository/stock_model.dart';
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
    order: (context) =>
        setUpStockMode(context) ? OrderScreen() : CircularLoading(),
    menuCatalog: (context) => CatalogNavigator(
          catalog: ModalRoute.of(context).settings.arguments,
        ),
    stockIngredient: (context) => setUpStockMode(context)
        ? IngredientScreen(
            ingredient: ModalRoute.of(context).settings.arguments,
          )
        : CircularLoading(),
    stockQuantity: (_) => QuantityScreen(),
    stockQuantityModal: (context) => QuantityModal(
          quantity: ModalRoute.of(context).settings.arguments,
        ),
    stockBatchModal: (context) => StockBatchModal(
          batch: ModalRoute.of(context).settings.arguments,
        ),
  };

  static bool setUpStockMode(BuildContext context) {
    final menu = context.watch<MenuModel>();
    if (menu.stockMode) return true;

    final stock = context.watch<StockModel>();
    final quantities = context.watch<QuantityRepo>();
    if (menu.isNotReady || stock.isNotReady || quantities.isNotReady) {
      return false;
    }

    menu.setUpStock(stock, quantities);
    return true;
  }
}
