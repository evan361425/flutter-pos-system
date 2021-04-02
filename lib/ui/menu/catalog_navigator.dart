import 'package:flutter/material.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';
import 'package:provider/provider.dart';

class CatalogNavigator extends StatelessWidget {
  CatalogNavigator({Key key, @required this.catalog}) : super(key: key);

  final CatalogModel catalog;
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        navigatorKey.currentState.pop();
        return false;
      },
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<CatalogModel>.value(value: catalog),
        ],
        builder: (_, __) => _navigator(context),
      ),
    );
  }

  Navigator _navigator(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: MenuRoutes.getBuilder(settings),
          settings: settings,
        );
      },
      observers: [CatalogRouteObserver(context)],
    );
  }
}

class CatalogRouteObserver extends RouteObserver<PageRoute> {
  CatalogRouteObserver(this.context);
  final BuildContext context;

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (previousRoute == null) {
      Navigator.of(context).pop();
    } else {
      super.didPop(route, previousRoute);
    }
  }
}
