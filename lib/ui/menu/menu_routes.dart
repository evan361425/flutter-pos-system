import 'package:flutter/material.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/product_model.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_modal.dart';
import 'package:provider/provider.dart';

import 'catalog/catalog_screen.dart';
import 'catalog/widgets/product_orderable_list.dart';
import 'product/product_screen.dart';

class MenuRoutes {
  static const String routeProduct = 'product';
  static const String routeProductOrder = 'product/order';
  static const String routeProductModal = 'product/modal';

  static WidgetBuilder getBuilder(RouteSettings settings) {
    switch (settings.name) {
      case routeProduct:
        if (settings.arguments == null) continue empty;

        return (_) => ChangeNotifierProvider<ProductModel>.value(
              value: settings.arguments,
              builder: (_, __) => ProductScreen(),
            );
      case routeProductModal:
        return (_) => ProductModal(product: settings.arguments);
      case routeProductOrder:
        return (BuildContext context) {
          final catalog = context.read<CatalogModel>();
          return ProductOrderableList(items: catalog.productList);
        };
      empty:
      default:
        return (_) => CatalogScreen();
    }
  }
}
