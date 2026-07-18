import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/stock/quantities_page.dart';
import 'package:possystem/ui/stock/replenishment_page.dart';
import 'package:possystem/ui/stock/stock_view.dart';
import 'package:possystem/ui/stock/widgets/replenishment_apply.dart';
import 'package:possystem/ui/stock/widgets/replenishment_modal.dart';
import 'package:possystem/ui/stock/widgets/stock_ingredient_modal.dart';
import 'package:possystem/ui/stock/widgets/stock_ingredient_restock_modal.dart';
import 'package:possystem/ui/stock/widgets/stock_quantity_modal.dart';

/// Stock feature routes.
List<RouteBase> stockRoutes = [
  GoRoute(
    name: AppRouteNames.stock,
    path: AppRouteNames.stock,
    pageBuilder: (ctx, state) =>
        NoTransitionPage(child: _l(const StockView(), state)),
    routes: [
      _createPrefixRoute(
        path: 'ingr',
        prefix: 'stock',
        routes: [
          GoRoute(
            name: AppRouteNames.stockIngredientCreate,
            path: 'create',
            parentNavigatorKey: Routes.rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(
              child: _l(const StockIngredientModal(), state),
            ),
          ),
          GoRoute(
            path: 'a/:id',
            parentNavigatorKey: Routes.rootNavigatorKey,
            redirect: _redirectIfMissed(
              path: 'stock',
              hasItem: (id) => Stock.instance.hasItem(id),
            ),
            routes: [
              GoRoute(
                name: AppRouteNames.stockIngredientUpdate,
                path: 'update',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final ingr = Stock.instance.getItem(
                    state.pathParameters['id']!,
                  )!;
                  return MaterialDialogPage(
                    child: _l(StockIngredientModal(ingredient: ingr), state),
                  );
                },
              ),
              GoRoute(
                name: AppRouteNames.stockIngredientRestock,
                path: 'restock',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final ingr = Stock.instance.getItem(
                    state.pathParameters['id']!,
                  )!;
                  return MaterialDialogPage(
                    child: _l(
                      StockIngredientRestockModal(ingredient: ingr),
                      state,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      _createPrefixRoute(
        path: 'repl',
        prefix: 'stock',
        routes: [
          GoRoute(
            name: AppRouteNames.stockReplenishmentCreate,
            path: 'create',
            parentNavigatorKey: Routes.rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(
              child: _l(const ReplenishmentModal(), state),
            ),
          ),
          GoRoute(
            path: 'a/:id',
            parentNavigatorKey: Routes.rootNavigatorKey,
            redirect: _redirectIfMissed(
              path: 'stock',
              hasItem: (id) =>
                  Stock.instance.getItem(id)?.hasReplenishment == true,
            ),
            routes: [
              GoRoute(
                name: AppRouteNames.stockReplenishmentUpdate,
                path: 'update',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final repl = Stock.instance
                      .getItem(state.pathParameters['id']!)!
                      .replenishment!;
                  return MaterialDialogPage(
                    child: _l(ReplenishmentModal(replenishment: repl), state),
                  );
                },
              ),
              GoRoute(
                name: AppRouteNames.stockReplenishmentPreview,
                path: 'preview',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final repl = Stock.instance
                      .getItem(state.pathParameters['id']!)!
                      .replenishment!;
                  return MaterialDialogPage(
                    child: _l(ReplenishmentApply(replenishment: repl), state),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      _createPrefixRoute(
        path: 'quantity',
        prefix: 'quantity',
        routes: [
          GoRoute(
            name: AppRouteNames.stockQuantityCreate,
            path: 'create',
            parentNavigatorKey: Routes.rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(
              child: _l(const StockQuantityModal(), state),
            ),
          ),
          GoRoute(
            path: 'a/:id',
            parentNavigatorKey: Routes.rootNavigatorKey,
            redirect: _redirectIfMissed(
              path: 'quantity',
              hasItem: (id) => Quantities.instance.hasItem(id),
            ),
            routes: [
              GoRoute(
                name: AppRouteNames.stockQuantityUpdate,
                path: 'update',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final qua = Quantities.instance.getItem(
                    state.pathParameters['id']!,
                  )!;
                  return MaterialDialogPage(
                    child: _l(StockQuantityModal(quantity: qua), state),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
