import 'package:flutter/material.dart';
import 'package:possystem/ui/menu/widgets/catalog_orderable_list.dart';
import 'package:possystem/ui/setting/widgets/theme_modal.dart';
import 'package:provider/provider.dart';

import 'models/menu/catalog_model.dart';
import 'models/repository/menu_model.dart';
import 'models/repository/quantity_repo.dart';
import 'models/repository/stock_model.dart';
import 'models/stock/ingredient_model.dart';
import 'models/stock/quantity_model.dart';
import 'models/stock/stock_batch_model.dart';
import 'ui/analysis/analysis_screen.dart';
import 'ui/cashier/cashier_screen.dart';
import 'ui/customer/customer_screen.dart';
import 'ui/invoicer/invoicer_screen.dart';
import 'ui/menu/catalog_navigator.dart';
import 'ui/menu/menu_screen.dart';
import 'ui/order/order_screen.dart';
import 'ui/printer/printer_screen.dart';
import 'ui/setting/setting_screen.dart';
import 'ui/setting/widgets/language_modal.dart';
import 'ui/stock/ingredient/ingredient_screen.dart';
import 'ui/stock/quantity/quantity_screen.dart';
import 'ui/stock/quantity/widgets/quantity_modal.dart';
import 'ui/stock/stock_batch/stock_batch_modal.dart';
import 'ui/stock/stock_screen.dart';
import 'ui/transfer/transfer_screen.dart';

class Routes {
  static const String analysis = 'analysis';
  static const String cashier = 'cashier';
  static const String customer = 'customer';
  static const String invoicer = 'invoicer';
  static const String menu = 'menu';
  static const String order = 'order';
  static const String printer = 'printer';
  static const String setting = 'setting';
  static const String stock = 'stock';
  static const String transfer = 'transfer';

  // sub-route
  static const String menuCatalog = 'menu/catalog';
  static const String menuReorder = 'menu/reorder';
  static const String stockBatchModal = 'stock/batch/modal';
  static const String stockQuantity = 'stock/quantity';
  static const String stockIngredient = 'stock/ingredient';
  static const String stockQuantityModal = 'stock/quantity/modal';
  static const String settingTheme = 'setting/theme';
  static const String settingLanguage = 'setting/language';

  static T arg<T>(BuildContext context) =>
      ModalRoute.of(context)!.settings.arguments as T;

  static final routes = <String, WidgetBuilder>{
    analysis: (_) => AnalysisScreen(),
    cashier: (_) => CashierScreen(),
    customer: (_) => CustomerScreen(),
    invoicer: (_) => InvoicerScreen(),
    menu: (_) => MenuScreen(),
    order: (_) => OrderScreen(),
    printer: (_) => PrinterScreen(),
    setting: (_) => SettingScreen(),
    stock: (_) => StockScreen(),
    transfer: (_) => TransferScreen(),
    // sub-route
    // menu
    menuCatalog: (context) =>
        CatalogNavigator(catalog: arg<CatalogModel>(context)),
    menuReorder: (context) => CatalogOrderableList(),
    // stock
    stockIngredient: (context) =>
        IngredientScreen(ingredient: arg<IngredientModel?>(context)),
    stockQuantity: (_) => QuantityScreen(),
    stockQuantityModal: (context) =>
        QuantityModal(quantity: arg<QuantityModel?>(context)),
    stockBatchModal: (context) =>
        StockBatchModal(batch: arg<StockBatchModel?>(context)),
    // setting
    settingLanguage: (_) => LanguageModal(),
    settingTheme: (_) => ThemeModal(),
  };

  static bool setUpStockMode(BuildContext context) {
    final menu = context.watch<MenuModel>();
    if (menu.stockMode) return true;

    final stock = context.watch<StockModel>();
    final quantities = context.watch<QuantityRepo>();
    if (!menu.isReady || !stock.isReady || !quantities.isReady) {
      return false;
    }
    print('setting up stock mode');

    menu.setUpStock(stock, quantities);
    return true;
  }
}
