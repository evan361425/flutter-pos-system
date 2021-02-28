import 'package:flutter/material.dart';

import 'ui/menu/catalog/catalog_screen.dart';
import 'ui/menu/product/product_screen.dart';

class Routes {
  static final String catalog = '/catalog';
  static final String product = '/product';

  static final routes = <String, Widget Function(BuildContext)>{
    catalog: (BuildContext context) => CatalogScreen(),
    product: (BuildContext context) => ProductScreen(),
  };
}
