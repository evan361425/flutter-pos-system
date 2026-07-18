import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/debug/debug_page.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/analysis_view.dart';
import 'package:possystem/ui/analysis/history_page.dart';
import 'package:possystem/ui/analysis/widgets/chart_modal.dart';
import 'package:possystem/ui/analysis/widgets/chart_reorder.dart';
import 'package:possystem/ui/analysis/widgets/history_order_modal.dart';
import 'package:possystem/ui/cashier/cashier_view.dart';
import 'package:possystem/ui/cashier/changer_modal.dart';
import 'package:possystem/ui/cashier/surplus_page.dart';
import 'package:possystem/ui/home/elf_page.dart';
import 'package:possystem/ui/home/home_page.dart';
import 'package:possystem/ui/home/mobile_more_view.dart';
import 'package:possystem/ui/home/settings_page.dart';
import 'package:possystem/ui/image_gallery_page.dart';
import 'package:possystem/ui/menu/menu_page.dart';
import 'package:possystem/ui/menu/product_page.dart';
import 'package:possystem/ui/menu/widgets/catalog_modal.dart';
import 'package:possystem/ui/menu/widgets/catalog_reorder.dart';
import 'package:possystem/ui/menu/widgets/product_ingredient_modal.dart';
import 'package:possystem/ui/menu/widgets/product_ingredient_reorder.dart';
import 'package:possystem/ui/menu/widgets/product_modal.dart';
import 'package:possystem/ui/menu/widgets/product_quantity_modal.dart';
import 'package:possystem/ui/menu/widgets/product_reorder.dart';
import 'package:possystem/ui/order/cart/split_bill_screen.dart';
import 'package:possystem/ui/order/order_checkout_page.dart';
import 'package:possystem/ui/order/order_page.dart';
import 'package:possystem/ui/order_attr/order_attribute_page.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_modal.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_option_modal.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_option_reorder.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_reorder.dart';
import 'package:possystem/ui/printer/printer_modal.dart';
import 'package:possystem/ui/printer/printer_page.dart';
import 'package:possystem/ui/printer/printer_settings_modal.dart';
import 'package:possystem/ui/stock/quantities_page.dart';
import 'package:possystem/ui/stock/replenishment_page.dart';
import 'package:possystem/ui/stock/stock_view.dart';
import 'package:possystem/ui/stock/widgets/replenishment_apply.dart';
import 'package:possystem/ui/stock/widgets/replenishment_modal.dart';
import 'package:possystem/ui/stock/widgets/stock_ingredient_modal.dart';
import 'package:possystem/ui/stock/widgets/stock_ingredient_restock_modal.dart';
import 'package:possystem/ui/stock/widgets/stock_quantity_modal.dart';
import 'package:possystem/ui/transit/transit_page.dart';
import 'package:possystem/ui/transit/transit_station.dart';

import 'analysis_routes.dart';
import 'app_route_names.dart';
import 'cashier_routes.dart';
import 'debug_routes.dart';
import 'elf_routes.dart';
import 'history_routes.dart';
import 'image_gallery_routes.dart';
import 'menu_routes.dart';
import 'order_attr_routes.dart';
import 'order_routes.dart';
import 'printer_routes.dart';
import 'settings_routes.dart';
import 'stock_routes.dart';
import 'transit_routes.dart';

export 'app_route_names.dart' show AppRouteNames, HomeMode, serializeRange;

class Routes {
  /// The base path of the app
  /// avoid using root because we bind it to GitHub page:
  /// https://github.com/evan361425/evan361425.github.io
  static const base = '/pos';

  /// The mode of the home page, should change the layout of the home page
  static final ValueNotifier<HomeMode> homeMode = ValueNotifier(
    .bottomNavigationBar,
  );

  /// Get the full path of the route
  static getRoute(String path) => 'https://evan361425.github.io$base/$path';

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Get the initial location of the app.
  ///
  /// if the user is new, redirect to menu page
  static get initLocation =>
      Cache.instance.get<bool>('tutorial.home.order') != true
      ? homeMode.value.isMobile()
            ? '$base/_'
            : '$base/_/menu' // if going to anal, the tutorial will conflicts with analysis page's tutorial
      : '$base/anal';

  /// Base redirect function
  ///
  /// redirect to the analysis page if the path is not started with the base path
  static String? _redirect(BuildContext ctx, GoRouterState state) {
    return state.uri.path.startsWith('$base/') ? null : '$base/anal';
  }

  /// Get the desired route config based on the width
  static RoutingConfig getDesiredRoute(double width) {
    switch (Breakpoint.find(width: width)) {
      case .compact:
      case .medium:
        homeMode.value = .bottomNavigationBar;
        return Routes._bottomNavConfig;
      case .expanded:
      case .large:
        homeMode.value = .drawer;
        return Routes._drawerConfig;
      case .extraLarge:
        homeMode.value = .rail;
        return Routes._drawerConfig;
    }
  }

  // Stateful navigation based on:
  // https://codewithandrea.com/articles/flutter-bottom-navigation-bar-nested-routes-gorouter/
  static final RoutingConfig _bottomNavConfig = RoutingConfig(
    routes: [
      GoRoute(
        path: base,
        redirect: _redirect,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) =>
                HomePage(shell: shell, mode: homeMode),
            // the order of this list should follow the order of the tabs
            branches: [
              StatefulShellBranch(routes: analysisRoutes),
              StatefulShellBranch(routes: stockRoutes),
              StatefulShellBranch(routes: cashierRoutes),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    name: Routes.others,
                    path: '_',
                    builder: (ctx, state) => _l(const MobileMoreView(), state),
                    routes: [
                      if (!isProd) ...debugRoutes,
                      ...menuRoutes,
                      ...printerRoutes,
                      ...stockRoutes.where(
                        (r) =>
                            r is GoRoute && r.path.startsWith('q') ||
                            r.path.contains('quantity'),
                      ),
                      ...orderAttrRoutes,
                      ...elfRoutes,
                      ...transitRoutes,
                      ...settingsRoutes,
                      ...imageGalleryRoutes,
                    ],
                  ),
                ],
              ),
            ],
          ),
          ..._routes,
        ],
      ),
    ],
  );

  static final RoutingConfig _drawerConfig = RoutingConfig(
    routes: [
      GoRoute(
        path: base,
        redirect: _redirect,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) =>
                HomePage(shell: shell, mode: homeMode),
            branches: [
              StatefulShellBranch(routes: analysisRoutes),
              StatefulShellBranch(routes: stockRoutes),
              StatefulShellBranch(routes: cashierRoutes),
              StatefulShellBranch(routes: orderAttrRoutes),
              StatefulShellBranch(routes: menuRoutes),
              StatefulShellBranch(routes: printerRoutes),
              StatefulShellBranch(
                routes: stockRoutes
                    .where((r) => r is GoRoute && r.path.contains('quantity'))
                    .toList(),
              ),
              StatefulShellBranch(routes: transitRoutes),
              StatefulShellBranch(routes: elfRoutes),
              StatefulShellBranch(routes: settingsRoutes),
              if (!isProd) StatefulShellBranch(routes: debugRoutes),
              StatefulShellBranch(
                routes: [
                  // This is fallback route for `_` which is the mobile more view
                  GoRoute(name: '_anal', path: '_', pageBuilder: _analBuilder),
                ],
              ),
            ],
          ),
          ..._routes,
        ],
      ),
    ],
  );

  // ==================== Routes in main navigation ========================

  static Page<dynamic> _analBuilder(BuildContext ctx, GoRouterState state) =>
      NoTransitionPage(child: _l(const AnalysisView(), state));

  // ==================== Other routes ====================

  static final _routes = [
    GoRoute(
      name: AppRouteNames.order,
      path: AppRouteNames.order,
      builder: (ctx, state) => _l(const OrderPage(), state),
      routes: [
        GoRoute(
          name: AppRouteNames.orderCheckout,
          path: 'details',
          builder: (ctx, state) => _l(const OrderCheckoutPage(), state),
        ),
        GoRoute(
          name: AppRouteNames.orderSplitBill,
          path: 'split-bill',
          builder: (ctx, state) => _l(const SplitBillScreen(), state),
        ),
      ],
    ),
    GoRoute(
      name: AppRouteNames.history,
      path: AppRouteNames.history,
      builder: (ctx, state) => _l(const HistoryPage(), state),
      routes: [
        GoRoute(
          name: AppRouteNames.historyOrder,
          path: 'order/:id',
          pageBuilder: (ctx, state) => MaterialDialogPage(
            child: _l(
              HistoryOrderModal(
                int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
              ),
              state,
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      name: AppRouteNames.imageGallery,
      path: AppRouteNames.imageGallery,
      pageBuilder: (ctx, state) =>
          MaterialDialogPage(child: _l(const ImageGalleryPage(), state)),
    ),
  ];

  // ==================== Route names ====================

  static const others = 'others';
  static const menu = 'menu';
  static const menuCatalogCreate = 'menu.catalog.create';
  static const menuCatalogUpdate = 'menu.catalog.update';
  static const menuCatalogReorder = 'menu.catalog.reorder';
  static const menuProduct = 'menu.product';
  static const menuProductUpdate = 'menu.product.update';
  static const menuProductReorder = 'menu.product.reorder';
  static const menuProductUpdateIngredient = 'menu.product.update.ingredient';
  static const menuProductReorderIngredient = 'menu.product.reorder.ingredient';
  static const orderAttr = 'oa';
  static const orderAttrCreate = 'oa.create';
  static const orderAttrUpdate = 'oa.update';
  static const orderAttrReorder = 'oa.reorder';
  static const orderAttrReorderOption = 'oa.reorder.option';
  static const stock = 'stock';
  static const stockIngrCreate = 'stock.ingr.create';
  static const stockIngrUpdate = 'stock.ingr.update';
  static const stockIngrRestock = 'stock.ingr.restock';
  static const stockRepl = 'stock.repl';
  static const stockReplCreate = 'stock.repl.create';
  static const stockReplUpdate = 'stock.repl.update';
  static const stockReplPreview = 'stock.repl.preview';
  static const quantities = 'quantity';
  static const quantityCreate = 'quantity.create';
  static const quantityUpdate = 'quantity.update';
  static const cashier = 'cashier';
  static const cashierChanger = 'cashier.changer';
  static const cashierSurplus = 'cashier.surplus';
  static const order = 'order';
  static const orderCheckout = 'order.checkout';
  static const history = 'history';
  static const historyOrder = 'history.order';
  static const anal = 'anal';
  static const chartCreate = 'chart.create';
  static const chartUpdate = 'chart.update';
  static const chartReorder = 'chart.reorder';
  static const transit = 'transit';
  static const transitStation = 'transit.station';
  static const elf = 'elf';
  static const imageGallery = 'imageGallery';
  static const settings = 'settings';
  static const settingsFeature = 'settings.feature';
  static const printer = 'printer';
  static const printerCreate = 'printer.create';
  static const printerSettings = 'printer.settings';
  static const printerUpdate = 'printer.update';
}

T _findEnum<T extends Enum>(Iterable<T> values, String? path, T other) {
  return values.firstWhere((e) => e.name == path, orElse: () => other);
}

DateTimeRange? _parseRange(String? val) {
  try {
    final ss = val?.split('-') ?? const <String>[];
    return DateTimeRange(
      start: DateTime(int.parse(ss[0]), int.parse(ss[1]), int.parse(ss[2])),
      end: DateTime(int.parse(ss[3]), int.parse(ss[4]), int.parse(ss[5])),
    );
  } catch (e) {
    return null;
  }
}

String? Function(BuildContext, GoRouterState) _redirectIfMissed({
  required String path,
  required bool Function(String id) hasItem,
}) {
  return (ctx, state) {
    final id = state.pathParameters['id'];
    // namedLocation is not allowed.
    return id == null || !hasItem(id) ? '${Routes.base}/$path' : null;
  };
}

GoRoute _createPrefixRoute({
  required String path,
  required String prefix,
  required List<RouteBase> routes,
}) {
  return GoRoute(
    path: path,
    redirect: (context, state) {
      return state.uri.path == '${Routes.base}/$prefix/$path'
          ? '${Routes.base}/$prefix'
          : null;
    },
    routes: routes,
  );
}

/// Log the screen view to Firebase Analytics
Widget _l(Widget w, GoRouterState state) {
  Log.ger('screen_view', {
    'screen_class': w.runtimeType.toString(),
    'screen_name': state.name,
  });

  return w;
}

/// Wrap the widget for mobile view
Widget _w(Widget child, String title) {
  child = Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: Breakpoint.medium.max),
      child: child,
    ),
  );

  if (Routes.homeMode.value.isMobile()) {
    return Scaffold(
      appBar: AppBar(title: Text(title), leading: const PopButton()),
      body: child,
    );
  }

  return child;
}
