import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/product_model.dart';
import 'package:possystem/ui/analysis/analysis_screen.dart';
import 'package:possystem/ui/auth/sign_in_screen.dart';
import 'package:possystem/ui/customer/customer_screen.dart';
import 'package:possystem/ui/menu/catalog/catalog_screen.dart';
import 'package:possystem/ui/menu/menu_screen.dart';
import 'package:possystem/ui/menu/product/product_screen.dart';
import 'package:possystem/ui/setting/setting_screen.dart';
import 'package:possystem/ui/spreadsheet/spreadsheet_screen.dart';
import 'package:possystem/ui/stock/stock_screen.dart';
import 'package:provider/provider.dart';

class Routes {
  static const String login = '/login';
  static const String setting = '/setting';

  static const String analysis = '/analysis';
  static const String customer = '/customer';
  static const String menu = '/menu';
  static const String catalog = '/menu/catalog';
  static const String product = '/menu/catalog/production';
  static const String spreadsheet = '/spreadsheet';
  static const String stock = '/stock';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => SignInScreen(),
    setting: (BuildContext context) => SettingScreen(),
    analysis: (BuildContext context) => AnalysisScreen(),
    customer: (BuildContext context) => CustomerScreen(),
    menu: (BuildContext context) => MenuScreen(),
    spreadsheet: (BuildContext context) => SpreadsheetScreen(),
    stock: (BuildContext context) => StockScreen(),
  };

  Routes._();

  static Route catalogRoute(CatalogModel catalog) {
    return CupertinoPageRoute(
      builder: (BuildContext context) => CatalogScreen(),
      settings: RouteSettings(arguments: catalog),
    );
  }

  static Route productRoute(ProductModel product) {
    return CupertinoPageRoute(
      builder: (BuildContext context) => ProductScreen(),
      settings: RouteSettings(arguments: product),
    );
  } //this is to prevent anyone from instantiate this object
}
