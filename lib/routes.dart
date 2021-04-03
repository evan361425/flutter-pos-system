import 'package:flutter/material.dart';

import 'models/menu/catalog_model.dart';
import 'ui/menu/catalog_navigator.dart';
import 'ui/menu/widgets/catalog_modal.dart';

class Routes {
  static final String catalog = '/catalog';
  static final String catalogModal = '/catalog/modal';

  static final routes = <String, Widget Function(BuildContext)>{
    catalog: (BuildContext context) {
      final CatalogModel catalog = ModalRoute.of(context).settings.arguments;
      assert(catalog != null);
      return CatalogNavigator(catalog: catalog);
    },
    catalogModal: (BuildContext context) {
      final CatalogModel catalog = ModalRoute.of(context).settings.arguments;
      return CatalogModal(catalog: catalog);
    }
  };
}
