import 'package:flutter/material.dart';
import 'package:possystem/ui/auth/sign_in_screen.dart';
import 'package:possystem/ui/menu/index.dart' as Menu;
import 'package:possystem/ui/setting/setting_screen.dart';
import 'package:possystem/ui/splash/splash_screen.dart';

class Routes {
  Routes._(); //this is to prevent anyone from instantiate this object

  static const String splash = '/splash';
  static const String login = '/login';
  static const String setting = '/setting';
  static const String menu = '/menu';
  static const String menu_catalog_add = '/menu/catalog/add';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    login: (BuildContext context) => SignInScreen(),
    setting: (BuildContext context) => SettingScreen(),
    menu: (BuildContext context) => Menu.HomeScreen(),
    menu_catalog_add: (BuildContext context) => Menu.CatalogDetailScreen(),
  };
}
