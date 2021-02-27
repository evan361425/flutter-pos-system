import 'package:flutter/material.dart';
import 'package:possystem/ui/auth/sign_in_screen.dart';
import 'package:possystem/ui/menu/catalog_navigator.dart';
import 'package:possystem/ui/setting/setting_screen.dart';
import 'package:possystem/ui/analysis/analysis_screen.dart';
import 'package:possystem/ui/customer/customer_screen.dart';
import 'package:possystem/ui/menu/menu_screen.dart';
import 'package:possystem/ui/spreadsheet/spreadsheet_screen.dart';
import 'package:possystem/ui/stock/stock_screen.dart';

class Routes {
  static const String login = '/login';
  static const String setting = '/setting';

  static const String analysis = '/analysis';
  static const String customer = '/customer';
  static const String menu = '/menu';
  static const String catalog = '/catalog';
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

  Routes._(); //this is to prevent anyone from instantiate this object
}
