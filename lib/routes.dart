import 'package:flutter/material.dart';
import 'package:possystem/ui/stock/stock_batch/stock_batch_modal.dart';

import 'models/menu/catalog_model.dart';
import 'ui/menu/catalog_navigator.dart';

class Routes {
  static final String catalog = 'catalog';
  static final String stockBatch = 'stock/batch';

  static final routes = <String, Widget Function(BuildContext)>{
    catalog: (BuildContext context) {
      final CatalogModel catalog = ModalRoute.of(context).settings.arguments;
      return CatalogNavigator(catalog: catalog);
    },
    stockBatch: (BuildContext context) {
      return StockBatchModal(batch: ModalRoute.of(context).settings.arguments);
    }
  };
}
