import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/product_model.dart';
import 'package:provider/provider.dart';

import '../catalog/catalog_screen.dart';
import '../product/product_screen.dart';

class CatalogNavigator extends StatefulWidget {
  final CatalogModel catalog;

  CatalogNavigator({Key key, @required this.catalog}) : super(key: key);

  @override
  CatalogNavigatorState createState() => CatalogNavigatorState();
}

class CatalogNavigatorState extends State<CatalogNavigator> {
  final navigatorKey = GlobalKey<NavigatorState>();

  ProductModel _product;
  ProductModel get product => _product;
  set product(ProductModel product) => setState(() => _product = product);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        navigatorKey.currentState.pop();
        return false;
      },
      child: MultiProvider(
        providers: [
          Provider.value(value: this),
          ChangeNotifierProvider<CatalogModel>.value(value: widget.catalog),
        ],
        builder: (_, __) => _navigator(),
      ),
    );
  }

  Navigator _navigator() {
    return Navigator(
      key: navigatorKey,
      pages: [
        CupertinoPage(
          key: ValueKey('menu/${widget.catalog.id}'),
          child: CatalogScreen(),
        ),
        if (product != null) _productPage(),
      ],
      onPopPage: (route, result) {
        if (product == null) {
          // Pop to menu
          Navigator.of(context).pop();
        } else {
          // Update the list of pages by setting _selectedBook to null
          product = null;
        }
        return false;
      },
    );
  }

  Page _productPage() {
    return MaterialPage(
      key: ValueKey('menu/${widget.catalog.id}/${product.id}'),
      child: ChangeNotifierProvider<ProductModel>.value(
        value: product,
        builder: (_, __) => ProductScreen(),
      ),
    );
  }
}
