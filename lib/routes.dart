import 'package:flutter/material.dart';
import 'package:possystem/ui/cashier/cashier_screen.dart';
import 'package:possystem/ui/customer/customer_screen.dart';
import 'package:possystem/ui/invoicer/invoicer_screen.dart';
import 'package:possystem/ui/menu/menu_screen.dart';
import 'package:possystem/ui/order/order_screen.dart';
import 'package:possystem/ui/printer/printer_screen.dart';
import 'package:possystem/ui/setting/setting_screen.dart';
import 'package:possystem/ui/setting/widgets/language_modal.dart';
import 'package:possystem/ui/transfer/transfer_screen.dart';
import 'package:provider/provider.dart';

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
  static final String menu = 'menu';
  static final String customer = 'customer';
  static final String setting = 'setting';
  static final String transfer = 'transfer';
  static final String cashier = 'cashier';
  static final String invoicer = 'invoicer';
  static final String printer = 'printer';
  static final String menuCatalog = 'menu/catalog';
  static const String stockBatchModal = 'stock/batch/modal';
  static const String stockQuantity = 'stock/quantity';
  static const String stockIngredient = 'stock/ingredient';
  static const String stockQuantityModal = 'stock/quantity/modal';
  static final String settingLanguage = 'setting/language';

  static final routes = <String, WidgetBuilder>{
    order: (context) => OrderScreen(),
    menu: (context) => MenuScreen(),
    customer: (context) => CustomerScreen(),
    setting: (context) => SettingScreen(),
    transfer: (context) => TransferScreen(),
    cashier: (context) => CashierScreen(),
    invoicer: (context) => InvoicerScreen(),
    printer: (context) => PrinterScreen(),
    menuCatalog: (context) =>
        CatalogNavigator(catalog: ModalRoute.of(context).settings.arguments),
    stockIngredient: (context) =>
        IngredientScreen(ingredient: ModalRoute.of(context).settings.arguments),
    stockQuantity: (_) => QuantityScreen(),
    stockQuantityModal: (context) =>
        QuantityModal(quantity: ModalRoute.of(context).settings.arguments),
    stockBatchModal: (context) =>
        StockBatchModal(batch: ModalRoute.of(context).settings.arguments),
    settingLanguage: (context) => LanguageModal(),
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
