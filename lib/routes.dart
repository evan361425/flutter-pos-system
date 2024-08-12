import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/debug/debug_page.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/services/cache.dart';
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
import 'package:possystem/ui/home/mobile_entry_view.dart';
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
import 'package:possystem/ui/order/order_checkout_page.dart';
import 'package:possystem/ui/order/order_page.dart';
import 'package:possystem/ui/order_attr/order_attribute_page.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_modal.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_option_modal.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_option_reorder.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_reorder.dart';
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

String serializeRange(DateTimeRange range) {
  final f = DateFormat('y-M-d');
  return "${f.format(range.start)}-${f.format(range.end)}";
}

class Routes {
  /// The base path of the app
  /// avoid using root because we bind it to GitHub page:
  /// https://github.com/evan361425/evan361425.github.io
  static const base = '/pos';

  /// The mode of the home page, should change the layout of the home page
  static final ValueNotifier<HomeMode> homeMode = ValueNotifier(HomeMode.bottomNavigationBar);

  /// Get the full path of the route
  static getRoute(String path) => 'https://evan361425.github.io$base/$path';

  /// Get the initial location of the app.
  ///
  /// if the user is new, redirect to menu page
  static get initLocation => Cache.instance.get<bool>('tutorial.home.order') != true
      ? homeMode.value == HomeMode.bottomNavigationBar
          ? '$base/others'
          : '$base/menu'
      : base;

  /// Get the desired route config based on the width
  static RoutingConfig getDesiredRoute(double width) {
    switch (Breakpoint.find(width: width)) {
      case Breakpoint.compact:
      case Breakpoint.medium:
        homeMode.value = HomeMode.bottomNavigationBar;
        return Routes._bottomNavConfig;
      case Breakpoint.expanded:
      case Breakpoint.large:
        homeMode.value = HomeMode.drawer;
        return Routes._drawerConfig;
      case Breakpoint.extraLarge:
        homeMode.value = HomeMode.rail;
        return Routes._drawerConfig;
    }
  }

  // Stateful navigation based on:
  // https://codewithandrea.com/articles/flutter-bottom-navigation-bar-nested-routes-gorouter/
  static final RoutingConfig _bottomNavConfig = RoutingConfig(routes: [
    GoRoute(
      path: base,
      redirect: (ctx, state) => state.uri.path.startsWith('$base/') ? null : '$base/anal',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => HomePage(shell: shell, mode: homeMode),
          // the order of this list should follow the order of the tabs
          branches: [
            StatefulShellBranch(routes: [_analysisRoute]),
            StatefulShellBranch(routes: [_stockRoute]),
            StatefulShellBranch(routes: [_cashierRoute]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: 'others',
                builder: (ctx, state) => const MobileEntryView(),
              )
            ]),
          ],
        ),
        _debugRoute,
        _menuRoute,
        _quantitiesRoute,
        _orderAttrsRoute,
        _elfRoute,
        _transitRoute,
        _settingsRoute,
        ..._routes,
      ],
    )
  ]);
  static final RoutingConfig _drawerConfig = RoutingConfig(routes: [
    GoRoute(
      path: base,
      redirect: (_, state) {
        return state.uri.path.startsWith('$base/') && state.uri.path != '$base/others' ? null : '$base/anal';
      },
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => HomePage(shell: shell, mode: homeMode),
          branches: [
            StatefulShellBranch(routes: [_analysisRoute]),
            StatefulShellBranch(routes: [_stockRoute]),
            StatefulShellBranch(routes: [_cashierRoute]),
            StatefulShellBranch(routes: [_orderAttrsRoute]),
            StatefulShellBranch(routes: [_menuRoute]),
            StatefulShellBranch(routes: [_quantitiesRoute]),
            StatefulShellBranch(routes: [_transitRoute]),
            StatefulShellBranch(routes: [_elfRoute]),
            StatefulShellBranch(routes: [_settingsRoute]),
            if (!isProd) StatefulShellBranch(routes: [_debugRoute]),
          ],
        ),
        ..._routes,
      ],
    ),
  ]);

  // ==================== Routes in main navigation ====================

  static final _analysisRoute = GoRoute(
    name: anal,
    path: 'anal',
    pageBuilder: (ctx, state) => const NoTransitionPage(child: AnalysisView()),
  );
  static final _stockRoute = GoRoute(
    name: stock,
    path: 'stock',
    pageBuilder: (ctx, state) => const NoTransitionPage(child: StockView()),
  );
  static final _cashierRoute = GoRoute(
    name: cashier,
    path: 'cashier',
    pageBuilder: (ctx, state) => const NoTransitionPage(child: CashierView()),
  );
  static final _orderAttrsRoute = GoRoute(
    name: orderAttr,
    path: 'oas',
    builder: (ctx, state) => const OrderAttributePage(),
  );
  static final _menuRoute = GoRoute(
    name: menu,
    path: 'menu',
    builder: (ctx, state) {
      final id = state.uri.queryParameters['id'];
      final mode = state.uri.queryParameters['mode'];
      final catalog = id != null ? Menu.instance.getItem(id) : null;
      return MenuPage(catalog: catalog, productOnly: mode == 'products');
    },
  );
  static final _quantitiesRoute = GoRoute(
    name: quantities,
    path: 'quantities',
    builder: (ctx, state) => const QuantitiesPage(),
  );
  static final _transitRoute = GoRoute(
    name: transit,
    path: 'transit',
    builder: (ctx, state) => const TransitPage(),
  );
  static final _elfRoute = GoRoute(
    name: elf,
    path: 'elf',
    builder: (ctx, state) => const ElfPage(),
  );
  static final _settingsRoute = GoRoute(
    name: settings,
    path: 'settings',
    builder: (ctx, state) => SettingsPage(focus: state.uri.queryParameters['f']),
  );
  static final _debugRoute = GoRoute(
    name: 'debug',
    path: 'debug',
    builder: (ctx, state) => const DebugPage(),
  );

  // ==================== Other routes ====================

  static final _routes = [
    _createPrefixRoute('chart', 'anal', [
      GoRoute(
        name: chartCreate,
        path: 'create',
        pageBuilder: (ctx, state) => const MaterialDialogPage(child: ChartModal()),
      ),
      GoRoute(
        name: chartUpdate,
        path: 'update/:id',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id']!;
          final chart = Analysis.instance.getItem(id);
          return MaterialDialogPage(child: ChartModal(chart: chart));
        },
      ),
      GoRoute(
        name: chartReorder,
        path: 'reorder',
        builder: (ctx, state) => const ChartReorder(),
      ),
    ]),
    _createPrefixRoute('ingredient', 'stock', [
      GoRoute(
        name: ingredientCreate,
        path: 'create',
        pageBuilder: (ctx, state) => const MaterialDialogPage(child: StockIngredientModal()),
      ),
      GoRoute(
        name: ingredientUpdate,
        path: 'update/:id',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialDialogPage(child: StockIngredientModal(ingredient: Stock.instance.getItem(id)));
        },
      ),
      GoRoute(
        name: ingredientRestock,
        path: 'restock/:id',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialDialogPage(child: StockIngredientRestockModal(ingredient: Stock.instance.getItem(id)));
        },
      ),
    ]),
    GoRoute(
      name: replenish,
      path: 'replenish',
      builder: (ctx, state) => const ReplenishmentPage(),
      routes: [
        GoRoute(
          name: replenishCreate,
          path: 'create',
          builder: (ctx, state) => const ReplenishmentModal(),
        ),
        GoRoute(
          name: replenishUpdate,
          path: 'update/:id',
          pageBuilder: (ctx, state) {
            final id = state.pathParameters['id'] ?? '';
            return MaterialDialogPage(
              child: ReplenishmentModal(replenishment: Replenisher.instance.getItem(id)),
            );
          },
        ),
        GoRoute(
          name: replenishApply,
          path: 'apply/:id',
          redirect: _redirectIfMissed(path: '/stock', hasItem: (id) => Replenisher.instance.hasItem(id)),
          builder: (ctx, state) {
            final id = state.pathParameters['id']!;
            return ReplenishmentApply(Replenisher.instance.getItem(id)!);
          },
        ),
      ],
    ),
    _createPrefixRoute('menu/catalog', 'menu', [
      GoRoute(
        name: menuCatalogCreate,
        path: 'create',
        pageBuilder: (ctx, state) {
          final id = state.uri.queryParameters['id'];
          final c = id == null ? null : Menu.instance.getItem(id);

          if (c == null) {
            return const MaterialDialogPage(child: CatalogModal());
          }
          return MaterialDialogPage(child: ProductModal(catalog: c));
        },
      ),
      GoRoute(
        name: menuCatalogUpdate,
        path: 'update/:id',
        pageBuilder: (ctx, state) => MaterialDialogPage(
          child: CatalogModal(
            catalog: Menu.instance.getItem(state.pathParameters['id'] ?? ''),
          ),
        ),
      ),
      GoRoute(
        name: menuCatalogReorder,
        path: 'reorder',
        builder: (ctx, state) => const CatalogReorder(),
      ),
    ]),
    GoRoute(
      name: menuProductReorder,
      // avoid conflict with product/:id
      path: 'menu/product_reorder/:id',
      redirect: _redirectIfMissed(path: '/menu', hasItem: (id) => Menu.instance.hasItem(id)),
      builder: (ctx, state) => ProductReorder(
        Menu.instance.getItem(state.pathParameters['id']!)!,
      ),
    ),
    GoRoute(
      name: menuProduct,
      path: 'menu/product/:id',
      redirect: _redirectIfMissed(path: '/menu', hasItem: (id) => Menu.instance.getProduct(id) != null),
      builder: (ctx, state) => ProductPage(
        product: Menu.instance.getProduct(state.pathParameters['id']!)!,
      ),
      routes: [
        GoRoute(
          name: menuProductUpdate,
          path: 'update',
          pageBuilder: (ctx, state) {
            // verified for parent
            final p = Menu.instance.getProduct(state.pathParameters['id']!)!;
            return MaterialDialogPage(child: ProductModal(product: p, catalog: p.catalog));
          },
        ),
        GoRoute(
          name: menuProductUpdateIngredient,
          path: 'updateDetails',
          pageBuilder: (ctx, state) {
            // verified for parent
            final p = Menu.instance.getProduct(state.pathParameters['id']!)!;
            final ing = p.getItem(state.uri.queryParameters['iid'] ?? '');
            final qid = state.uri.queryParameters['qid'];
            if (ing == null || qid == null) {
              return MaterialDialogPage(child: ProductIngredientModal(product: p, ingredient: ing));
            }

            return MaterialDialogPage(
              child: ProductQuantityModal(
                quantity: ing.getItem(qid),
                ingredient: ing,
              ),
            );
          },
        ),
        GoRoute(
          name: menuProductReorderIngredient,
          path: 'reorder',
          builder: (ctx, state) => ProductIngredientReorder(
            Menu.instance.getProduct(state.pathParameters['id']!)!,
          ),
        ),
      ],
    ),
    _createPrefixRoute('quantity', 'quantities', [
      GoRoute(
        name: quantityCreate,
        path: 'create',
        pageBuilder: (ctx, state) => const MaterialDialogPage(child: StockQuantityModal()),
      ),
      GoRoute(
        name: quantityUpdate,
        path: 'update/:id',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialDialogPage(
            child: StockQuantityModal(quantity: Quantities.instance.getItem(id)),
          );
        },
      ),
    ]),
    _createPrefixRoute('oa', 'oas', [
      GoRoute(
        name: orderAttrCreate,
        path: 'create',
        pageBuilder: (ctx, state) {
          final id = state.uri.queryParameters['id'];
          final oa = id == null ? null : OrderAttributes.instance.getItem(id);

          if (oa == null) {
            return const MaterialDialogPage(child: OrderAttributeModal());
          }
          return MaterialDialogPage(child: OrderAttributeOptionModal(oa));
        },
      ),
      GoRoute(
        name: orderAttrUpdate,
        path: 'update/:id',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'];
          final oid = state.uri.queryParameters['oid'];
          final oa = id == null ? null : OrderAttributes.instance.getItem(id);

          if (oid == null || oa == null) {
            // edit or new oa
            return MaterialDialogPage(child: OrderAttributeModal(attribute: oa));
          }
          return MaterialDialogPage(child: OrderAttributeOptionModal(oa, option: oa.getItem(oid)));
        },
      ),
      GoRoute(
        name: orderAttrReorder,
        path: 'reorder',
        builder: (ctx, state) => const OrderAttributeReorder(),
      ),
      GoRoute(
        name: orderAttrReorderOption,
        path: 'reorder/:id',
        redirect: _redirectIfMissed(path: '/oa', hasItem: (id) => OrderAttributes.instance.hasItem(id)),
        builder: (ctx, state) {
          return OrderAttributeOptionReorder(
            attribute: OrderAttributes.instance.getItem(
              state.pathParameters['id']!,
            )!,
          );
        },
      ),
    ]),
    GoRoute(
      name: cashierChanger,
      path: 'cashier/changer',
      pageBuilder: (ctx, state) => const MaterialDialogPage(child: ChangerModal()),
    ),
    GoRoute(
      name: cashierSurplus,
      path: 'cashier/surplus',
      builder: (ctx, state) => const CashierSurplus(),
    ),
    GoRoute(
      name: transitStation,
      path: 'transit/:method/:type',
      builder: (ctx, state) {
        final method = _findEnum(
          TransitMethod.values,
          state.pathParameters['method'],
          TransitMethod.plainText,
        );
        final type = _findEnum(
          TransitCatalog.values,
          state.pathParameters['type'],
          TransitCatalog.model,
        );
        final range = _parseRange(state.uri.queryParameters['range']);

        return TransitStation(
          method: method,
          catalog: type,
          range: range,
        );
      },
    ),
    GoRoute(
      name: settingsFeature,
      path: 'settings/:feature',
      builder: (ctx, state) {
        final f = state.pathParameters['feature'];
        final feature = Feature.values.firstWhereOrNull((e) => e.name == f) ?? Feature.theme;
        return ItemListScaffold(feature: feature);
      },
    ),
    GoRoute(
      name: order,
      path: 'order',
      builder: (ctx, state) => const OrderPage(),
      routes: [
        GoRoute(
          name: orderDetails,
          path: 'details',
          builder: (ctx, state) => const OrderDetailsPage(),
        ),
      ],
    ),
    GoRoute(
      name: history,
      path: 'history',
      builder: (ctx, state) => const HistoryPage(),
      routes: [
        GoRoute(
          name: historyOrder,
          path: 'order/:id',
          pageBuilder: (ctx, state) => MaterialDialogPage(
            child: HistoryOrderModal(int.tryParse(state.pathParameters['id'] ?? '0') ?? 0),
          ),
        )
      ],
    ),
    GoRoute(
      name: imageGallery,
      path: 'imageGallery',
      // TODO: use dialog
      builder: (ctx, state) => const ImageGalleryPage(),
    ),
  ];

  // ==================== Route names ====================

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
  static const ingredientCreate = 'ingredient.create';
  static const ingredientUpdate = 'ingredient.update';
  static const ingredientRestock = 'ingredient.restock';
  static const quantities = 'quantity';
  static const quantityCreate = 'quantity.create';
  static const quantityUpdate = 'quantity.update';
  static const replenish = 'repl';
  static const replenishCreate = 'repl.create';
  static const replenishUpdate = 'repl.update';
  static const replenishApply = 'repl.apply';
  static const cashier = 'cashier';
  static const cashierChanger = 'cashier.changer';
  static const cashierSurplus = 'cashier.surplus';
  static const order = 'order';
  static const orderDetails = 'order.details';
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
    return id == null || !hasItem(id) ? Routes.base + path : null;
  };
}

GoRoute _createPrefixRoute(String path, String redirect, List<RouteBase> routes) {
  return GoRoute(
    name: '_$path',
    path: path,
    redirect: (context, state) => state.name == '_$path' ? '${Routes.base}/$redirect' : null,
    routes: routes,
  );
}

enum HomeMode {
  bottomNavigationBar,
  drawer,
  rail,
}
