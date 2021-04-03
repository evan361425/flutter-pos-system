import 'package:flutter/material.dart';
import 'package:possystem/components/empty_body.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_list.dart';
import 'package:provider/provider.dart';

class CatalogBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();

    if (catalog == null || catalog.length == 0) {
      return EmptyBody('menu.catalog.empty_body');
    }

    final stock = context.watch<StockModel>();
    if (stock.isReady) {
      // get sorted products
      return ProductList(
        products: catalog.productList,
        stock: stock,
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
