import 'package:flutter/material.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_modal.dart';
import 'package:possystem/ui/menu/widgets/catalog_modal.dart';
import 'package:provider/provider.dart';

import 'catalog/catalog_screen.dart';
import 'catalog/widgets/product_orderable_list.dart';
import 'product/product_screen.dart';

class MenuRoutes {
  static const String routeProduct = 'product';
  static const String routeProductOrder = 'product/order';
  static const String routeProductModal = 'product/modal';
  static const String routeCatalogModal = 'catalog/modal';

  static WidgetBuilder getBuilder(RouteSettings settings) {
    switch (settings.name) {
      case routeProduct:
        return (_) => ChangeNotifierProvider<ProductModel>.value(
              value: settings.arguments,
              builder: (_, __) => ProductScreen(),
            );
      case routeProductOrder:
        return (BuildContext context) {
          final catalog = context.read<CatalogModel>();
          return ProductOrderableList(items: catalog.productList);
        };
      case routeProductModal:
        return (_) => ProductModal(product: settings.arguments);
      case routeCatalogModal:
        return (_) => CatalogModal(catalog: settings.arguments);
      default:
        return (_) => CatalogScreen();
    }
  }
}
