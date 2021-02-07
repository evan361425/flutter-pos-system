import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/ui/menu/catalog/catalog_screen.dart';
import 'package:possystem/ui/menu/product/product_screen.dart';
import 'package:provider/provider.dart';

class CatalogNavigator extends StatelessWidget {
  final navigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final CatalogModel catalog =
        ModalRoute.of(context).settings.arguments ?? CatalogModel.empty();
    final popRoot = () => Navigator.of(context).pop();
    Logger().d('${catalog.isReady ? 'Edit' : 'Create'} catalog');

    return ChangeNotifierProvider<CatalogModel>.value(
      value: catalog,
      child: WillPopScope(
        child: Navigator(
          key: navigator,
          initialRoute: CatalogRoutes.root,
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) =>
                CatalogRoutes.builders[settings.name](context, popRoot),
            settings: settings,
          ),
        ),
        onWillPop: () async {
          if (navigator.currentState.canPop()) {
            navigator.currentState.pop();
            return false;
          } else {
            return true;
          }
        },
      ),
    );
  }
}

typedef NavWidgetBuilder = Widget Function(
  BuildContext context,
  void Function() popRoot,
);

class CatalogRoutes {
  static const String root = '/';
  static const String product = '/product';

  static final Map<String, NavWidgetBuilder> builders = {
    root: (_, popRoot) => CatalogScreen(popRoot: popRoot),
    product: (_, __) => ProductScreen(),
  };
}
