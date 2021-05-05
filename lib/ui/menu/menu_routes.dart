import 'package:flutter/material.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/product/widgets/quantity_search_scaffold.dart';
import 'package:possystem/ui/splash/not_found_splash.dart';
import 'package:provider/provider.dart';

import 'catalog/catalog_screen.dart';
import 'catalog/widgets/product_modal.dart';
import 'catalog/widgets/product_orderable_list.dart';
import 'product/product_screen.dart';
import 'product/widgets/ingredient_modal.dart';
import 'product/widgets/ingredient_search_scaffold.dart';
import 'widgets/catalog_modal.dart';

class MenuRoutes {
  static const String catalog = 'catalog/screen';
  static const String catalogModal = 'catalog/modal';
  static const String product = 'product';
  static const String productOrder = 'product/order';
  static const String productModal = 'product/modal';
  static const String productIngredient = 'product/ingredient';
  static const String productIngredientSearch = 'product/ingredient/search';
  static const String productQuantitySearch = 'product/quantity/search';

  static WidgetBuilder getBuilder(RouteSettings settings) {
    switch (settings.name) {
      case catalog:
        return (_) => CatalogScreen();
      case catalogModal:
        return (_) => CatalogModal(catalog: settings.arguments);
      case product:
        return (_) => ChangeNotifierProvider<ProductModel>.value(
              value: settings.arguments,
              builder: (context, __) => Routes.setUpStockMode(context)
                  ? ProductScreen()
                  : Center(child: CircularProgressIndicator()),
            );
      case productOrder:
        return (BuildContext context) {
          final catalog = context.read<CatalogModel>();
          return ProductOrderableList(items: catalog.productList);
        };
      case productModal:
        return (_) => ProductModal(product: settings.arguments);
      case productIngredient:
        return (_) => IngredientModal(ingredient: settings.arguments);
      case productIngredientSearch:
        return (_) => IngredientSearchScaffold(text: settings.arguments);
      case productQuantitySearch:
        return (_) => QuantitySearchScaffold(text: settings.arguments);
      default:
        print(settings);
        return (_) => NotFoundSplash();
    }
  }
}
