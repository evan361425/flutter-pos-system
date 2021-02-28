import 'package:flutter/material.dart';

import 'catalog/catalog_screen.dart';
import 'menu_screen.dart';
import 'product/product_screen.dart';

class MenuRoutes {
  static final String catalog = '/catalog';
  static final String product = '/product';

  static final routes = <String, Widget Function(BuildContext)>{
    '/': (BuildContext context) => MenuScreen(),
    catalog: (BuildContext context) => CatalogScreen(),
    product: (BuildContext context) => ProductScreen(),
  };
}
