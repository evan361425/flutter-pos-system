import 'package:flutter/material.dart';

import 'models/menu/catalog_model.dart';
import 'ui/menu/catalog_navigator.dart';

class Routes {
  static final String catalog = '/catalog';

  static final routes = <String, Widget Function(BuildContext)>{
    catalog: (BuildContext context) {
      final CatalogModel catalog = ModalRoute.of(context).settings.arguments;
      return CatalogNavigator(catalog: catalog);
    },
  };
}
