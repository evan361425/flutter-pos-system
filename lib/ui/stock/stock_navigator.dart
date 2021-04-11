import 'package:flutter/material.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/ui/home_container.dart';
import 'package:possystem/ui/stock/stock_routes.dart';
import 'package:provider/provider.dart';

class StockNavigator extends StatelessWidget {
  StockNavigator({Key key}) : super(key: key);

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (navigatorKey.currentState.canPop()) {
          navigatorKey.currentState.pop();
        } else {
          HomeContainer.tabController.index = 0;
        }
        return false;
      },
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<StockBatchRepo>(
            create: (_) => StockBatchRepo(),
          ),
        ],
        builder: (_, __) => _navigator(context),
      ),
    );
  }

  Widget _navigator(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: StockRoutes.getBuilder(settings),
          settings: settings,
        );
      },
      observers: [_StockRouteObserver()],
    );
  }
}

class _StockRouteObserver extends RouteObserver<PageRoute> {
  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (previousRoute != null) {
      super.didPop(route, previousRoute);
    }
  }
}
