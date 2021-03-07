import 'package:flutter/material.dart';

import 'models/catalog_model.dart';
import 'ui/menu/navigators/catalog_navigator.dart';
import 'ui/menu/product/product_screen.dart';

class Routes {
  static final String catalog = '/catalog';
  static final String product = '/product';

  static final routes = <String, Widget Function(BuildContext)>{
    catalog: (BuildContext context) {
      final CatalogModel catalog = ModalRoute.of(context).settings.arguments;
      assert(catalog != null);
      return CatalogNavigator(catalog: catalog);
    },
    product: (BuildContext context) => ProductScreen(),
  };
}
