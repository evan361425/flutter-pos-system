import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/menu/menu_page.dart';
import 'package:possystem/ui/menu/product_page.dart';
import 'package:possystem/ui/menu/widgets/catalog_modal.dart';
import 'package:possystem/ui/menu/widgets/catalog_reorder.dart';
import 'package:possystem/ui/menu/widgets/product_ingredient_modal.dart';
import 'package:possystem/ui/menu/widgets/product_ingredient_reorder.dart';
import 'package:possystem/ui/menu/widgets/product_modal.dart';
import 'package:possystem/ui/menu/widgets/product_quantity_modal.dart';
import 'package:possystem/ui/menu/widgets/product_reorder.dart';

/// Menu feature routes.
List<RouteBase> menuRoutes = [
  GoRoute(
    name: AppRouteNames.menu,
    path: AppRouteNames.menu,
    pageBuilder: (ctx, state) => _l(const MenuPage(), state),
    routes: [
      _createPrefixRoute(
        path: 'catalog',
        prefix: 'menu',
        routes: [
          GoRoute(
            name: AppRouteNames.menuCatalogCreate,
            path: 'create',
            parentNavigatorKey: Routes.rootNavigatorKey,
            pageBuilder: (ctx, state) =>
                MaterialDialogPage(child: _l(const CatalogModal(), state)),
          ),
          GoRoute(
            name: AppRouteNames.menuCatalogReorder,
            path: 'reorder',
            parentNavigatorKey: Routes.rootNavigatorKey,
            pageBuilder: (ctx, state) =>
                MaterialDialogPage(child: _l(const CatalogReorder(), state)),
          ),
          GoRoute(
            path: 'a/:id',
            parentNavigatorKey: Routes.rootNavigatorKey,
            redirect: _redirectIfMissed(
              path: 'menu',
              hasItem: (id) => Menu.instance.hasItem(id),
            ),
            routes: [
              GoRoute(
                name: AppRouteNames.menuCatalogUpdate,
                path: 'update',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final catalog = Menu.instance.getItem(
                    state.pathParameters['id']!,
                  )!;
                  return MaterialDialogPage(
                    child: _l(CatalogModal(catalog: catalog), state),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      _createPrefixRoute(
        path: 'product',
        prefix: 'menu',
        routes: [
          GoRoute(
            name: AppRouteNames.menuProduct,
            path: 'p/:id',
            parentNavigatorKey: Routes.rootNavigatorKey,
            redirect: _redirectIfMissed(
              path: 'menu',
              hasItem: (id) => Menu.instance.getProduct(id) != null,
            ),
            pageBuilder: (ctx, state) {
              final product = Menu.instance.getProduct(
                state.pathParameters['id']!,
              )!;
              return _l(ProductPage(product: product), state);
            },
            routes: [
              GoRoute(
                name: AppRouteNames.menuProductReorder,
                path: 'reorder',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) => MaterialDialogPage(
                  child: _l(const ProductReorder(), state),
                ),
              ),
              GoRoute(
                name: AppRouteNames.menuProductUpdateIngredient,
                path: 'update/ingredient',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) => MaterialDialogPage(
                  child: _l(const ProductIngredientModal(), state),
                ),
              ),
              GoRoute(
                name: AppRouteNames.menuProductReorderIngredient,
                path: 'reorder/ingredient',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) => MaterialDialogPage(
                  child: _l(const ProductIngredientReorder(), state),
                ),
              ),
              GoRoute(
                name: AppRouteNames.menuProductUpdate,
                path: 'update',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) =>
                    MaterialDialogPage(child: _l(const ProductModal(), state)),
              ),
              GoRoute(
                name: AppRouteNames.menuProductUpdateQuantity,
                path: 'update/quantity',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) => MaterialDialogPage(
                  child: _l(const ProductQuantityModal(), state),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
