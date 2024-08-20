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

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

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
      redirect: (ctx, state) {
        return state.uri.path.startsWith('$base/') ? null : '$base/anal';
      },
      parentNavigatorKey: rootNavigatorKey,
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
                name: Routes.others,
                path: 'others',
                builder: (ctx, state) => const MobileEntryView(),
                routes: [
                  if (!isProd) _debugRoute,
                  _menuRoute,
                  _quantitiesRoute,
                  _orderAttrsRoute,
                  _elfRoute,
                  _transitRoute,
                  _settingsRoute,
                ],
              ),
            ]),
          ],
        ),
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
      parentNavigatorKey: rootNavigatorKey,
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
        GoRoute(
          name: Routes.others,
          path: 'others',
          redirect: (context, state) => '$base/anal',
        ),
        ..._routes,
      ],
    ),
  ]);

  // ==================== Routes in main navigation ====================

  static final _analysisRoute = GoRoute(
    name: anal,
    path: 'anal',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (ctx, state) => const NoTransitionPage(child: AnalysisView()),
    routes: [
      _createPrefixRoute(path: 'chart', prefix: 'anal', routes: [
        GoRoute(
          name: chartCreate,
          path: 'create',
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (ctx, state) => const MaterialDialogPage(child: ChartModal()),
        ),
        GoRoute(
          name: chartReorder,
          path: 'reorder',
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (ctx, state) => const MaterialDialogPage(child: ChartReorder()),
        ),
        GoRoute(
          path: 'a/:id',
          parentNavigatorKey: rootNavigatorKey,
          redirect: _redirectIfMissed(path: 'anal', hasItem: (id) => Analysis.instance.hasItem(id)),
          routes: [
            GoRoute(
              name: chartUpdate,
              path: 'update',
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (ctx, state) {
                final chart = Analysis.instance.getItem(state.pathParameters['id']!)!;
                return MaterialDialogPage(child: ChartModal(chart: chart));
              },
            ),
          ],
        ),
      ]),
    ],
  );
  static final _stockRoute = GoRoute(
    name: stock,
    path: 'stock',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (ctx, state) => const NoTransitionPage(child: StockView()),
    routes: [
      _createPrefixRoute(path: 'ingr', prefix: 'stock', routes: [
        GoRoute(
          name: stockIngrCreate,
          path: 'create',
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (ctx, state) => const MaterialDialogPage(child: StockIngredientModal()),
        ),
        GoRoute(
          path: 'a/:id',
          parentNavigatorKey: rootNavigatorKey,
          redirect: _redirectIfMissed(path: 'stock', hasItem: (id) => Stock.instance.hasItem(id)),
          routes: [
            GoRoute(
              name: stockIngrUpdate,
              path: 'update',
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (ctx, state) {
                final ingr = Stock.instance.getItem(state.pathParameters['id']!)!;
                return MaterialDialogPage(child: StockIngredientModal(ingredient: ingr));
              },
            ),
            GoRoute(
              name: stockIngrRestock,
              path: 'restock',
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (ctx, state) {
                final ingr = Stock.instance.getItem(state.pathParameters['id']!)!;
                return MaterialDialogPage(child: StockIngredientRestockModal(ingredient: ingr));
              },
            ),
          ],
        ),
      ]),
      GoRoute(
        name: stockRepl,
        path: 'repl',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (ctx, state) => const MaterialDialogPage(child: ReplenishmentPage()),
        routes: [
          GoRoute(
            name: stockReplCreate,
            path: 'create',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) => const MaterialDialogPage(child: ReplenishmentModal()),
          ),
          GoRoute(
            path: 'a/:id',
            parentNavigatorKey: rootNavigatorKey,
            redirect: _redirectIfMissed(path: 'stock/repl', hasItem: (id) => Replenisher.instance.hasItem(id)),
            routes: [
              GoRoute(
                name: stockReplUpdate,
                path: 'update',
                parentNavigatorKey: rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final repl = Replenisher.instance.getItem(state.pathParameters['id']!)!;
                  return MaterialDialogPage(child: ReplenishmentModal(replenishment: repl));
                },
              ),
              GoRoute(
                name: stockReplPreview,
                path: 'preview',
                parentNavigatorKey: rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final repl = Replenisher.instance.getItem(state.pathParameters['id']!)!;
                  return MaterialDialogPage(child: ReplenishmentPreviewPage(repl));
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
  static final _cashierRoute = GoRoute(
    name: cashier,
    path: 'cashier',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (ctx, state) => const NoTransitionPage(child: CashierView()),
    routes: [
      GoRoute(
        name: cashierChanger,
        path: 'changer',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (ctx, state) => const MaterialDialogPage(child: ChangerModal()),
      ),
      GoRoute(
        name: cashierSurplus,
        path: 'surplus',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (ctx, state) => const MaterialDialogPage(child: CashierSurplus()),
      ),
    ],
  );
  static final _orderAttrsRoute = GoRoute(
    name: orderAttr,
    path: 'order_attr',
    parentNavigatorKey: rootNavigatorKey,
    builder: (ctx, state) => const OrderAttributePage(),
    routes: [
      GoRoute(
        name: orderAttrCreate,
        path: 'create',
        parentNavigatorKey: rootNavigatorKey,
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
        name: orderAttrReorder,
        path: 'reorder',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (ctx, state) => const MaterialDialogPage(child: OrderAttributeReorder()),
      ),
      GoRoute(
        path: 'a/:id',
        parentNavigatorKey: rootNavigatorKey,
        redirect: _redirectIfMissed(path: 'order_attr', hasItem: (id) => OrderAttributes.instance.hasItem(id)),
        routes: [
          GoRoute(
            name: orderAttrUpdate,
            path: 'update',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) {
              final id = state.pathParameters['id']!;
              final oid = state.uri.queryParameters['oid'];
              final oa = OrderAttributes.instance.getItem(id)!;

              return MaterialDialogPage(
                child: oid == null
                    // edit order attr
                    ? OrderAttributeModal(attribute: oa)
                    // edit order attr option
                    : OrderAttributeOptionModal(oa, option: oa.getItem(oid)),
              );
            },
          ),
          GoRoute(
            name: orderAttrReorderOption,
            path: 'reorder',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) {
              final oa = OrderAttributes.instance.getItem(state.pathParameters['id']!)!;
              return MaterialDialogPage(child: OrderAttributeOptionReorder(attribute: oa));
            },
          ),
        ],
      ),
    ],
  );
  static final _menuRoute = GoRoute(
    name: menu,
    path: 'menu',
    parentNavigatorKey: rootNavigatorKey,
    builder: (ctx, state) {
      final id = state.uri.queryParameters['id'];
      final mode = state.uri.queryParameters['mode'];
      final catalog = id != null ? Menu.instance.getItem(id) : null;
      return MenuPage(catalog: catalog, productOnly: mode == 'products');
    },
    routes: [
      _createPrefixRoute(path: 'catalog', prefix: 'menu', routes: [
        GoRoute(
          name: menuCatalogCreate,
          path: 'create',
          parentNavigatorKey: rootNavigatorKey,
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
          name: menuCatalogReorder,
          path: 'reorder',
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (ctx, state) => const MaterialDialogPage(child: CatalogReorder()),
        ),
        GoRoute(
          path: 'a/:id',
          parentNavigatorKey: rootNavigatorKey,
          redirect: _redirectIfMissed(path: 'menu', hasItem: (id) => Menu.instance.hasItem(id)),
          routes: [
            GoRoute(
              name: menuCatalogUpdate,
              path: 'update',
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (ctx, state) {
                final catalog = Menu.instance.getItem(state.pathParameters['id'] ?? '');
                return MaterialDialogPage(child: CatalogModal(catalog: catalog));
              },
            ),
            GoRoute(
              name: menuProductReorder,
              path: 'reorder',
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (ctx, state) {
                final catalog = Menu.instance.getItem(state.pathParameters['id']!)!;
                return MaterialDialogPage(child: ProductReorder(catalog));
              },
            ),
          ],
        ),
      ]),
      GoRoute(
        name: menuProduct,
        path: 'product/:id',
        parentNavigatorKey: rootNavigatorKey,
        redirect: _redirectIfMissed(path: 'menu', hasItem: (id) => Menu.instance.getProduct(id) != null),
        builder: (ctx, state) {
          final product = Menu.instance.getProduct(state.pathParameters['id']!)!;
          return ProductPage(product: product);
        },
        routes: [
          GoRoute(
            name: menuProductUpdate,
            path: 'update',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) {
              final product = Menu.instance.getProduct(state.pathParameters['id']!)!;
              return MaterialDialogPage(child: ProductModal(product: product, catalog: product.catalog));
            },
          ),
          GoRoute(
            name: menuProductUpdateIngredient,
            path: 'update_details',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) {
              // verified for parent
              final p = Menu.instance.getProduct(state.pathParameters['id']!)!;
              final ingr = p.getItem(state.uri.queryParameters['iid'] ?? '');
              final qid = state.uri.queryParameters['qid'];
              if (ingr == null || qid == null) {
                return MaterialDialogPage(child: ProductIngredientModal(product: p, ingredient: ingr));
              }

              final qua = ingr.getItem(qid);
              return MaterialDialogPage(child: ProductQuantityModal(quantity: qua, ingredient: ingr));
            },
          ),
          GoRoute(
            name: menuProductReorderIngredient,
            path: 'reorder',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) {
              final ingr = Menu.instance.getProduct(state.pathParameters['id']!)!;
              return MaterialDialogPage(child: ProductIngredientReorder(ingr));
            },
          ),
        ],
      ),
    ],
  );
  static final _quantitiesRoute = GoRoute(
    name: quantities,
    path: 'quantities',
    parentNavigatorKey: rootNavigatorKey,
    builder: (ctx, state) => const QuantitiesPage(),
    routes: [
      GoRoute(
        name: quantityCreate,
        path: 'create',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (ctx, state) => const MaterialDialogPage(child: StockQuantityModal()),
      ),
      GoRoute(
        path: 'a/:id',
        parentNavigatorKey: rootNavigatorKey,
        redirect: _redirectIfMissed(path: 'menu', hasItem: (id) => Quantities.instance.hasItem(id)),
        routes: [
          GoRoute(
            name: quantityUpdate,
            path: 'update',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) {
              final qua = Quantities.instance.getItem(state.pathParameters['id']!)!;
              return MaterialDialogPage(child: StockQuantityModal(quantity: qua));
            },
          ),
        ],
      ),
    ],
  );
  static final _transitRoute = GoRoute(
    name: transit,
    path: 'transit',
    parentNavigatorKey: rootNavigatorKey,
    builder: (ctx, state) => const TransitPage(),
    routes: [
      GoRoute(
        name: transitStation,
        path: ':method/:type',
        parentNavigatorKey: rootNavigatorKey,
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
    ],
  );
  static final _elfRoute = GoRoute(
    name: elf,
    path: 'elf',
    parentNavigatorKey: rootNavigatorKey,
    builder: (ctx, state) => const ElfPage(),
  );
  static final _settingsRoute = GoRoute(
    name: settings,
    path: 'settings',
    parentNavigatorKey: rootNavigatorKey,
    builder: (ctx, state) => SettingsPage(focus: state.uri.queryParameters['f']),
    routes: [
      GoRoute(
        name: settingsFeature,
        path: ':feature',
        parentNavigatorKey: rootNavigatorKey,
        builder: (ctx, state) {
          final f = state.pathParameters['feature'];
          final feature = Feature.values.firstWhereOrNull((e) => e.name == f) ?? Feature.theme;
          return ItemListScaffold(feature: feature);
        },
      ),
    ],
  );
  static final _debugRoute = GoRoute(
    name: 'debug',
    path: 'debug',
    parentNavigatorKey: rootNavigatorKey,
    builder: (ctx, state) => const DebugPage(),
  );

  // ==================== Other routes ====================

  static final _routes = [
    GoRoute(
      name: order,
      path: 'order',
      parentNavigatorKey: rootNavigatorKey,
      builder: (ctx, state) => const OrderPage(),
      routes: [
        GoRoute(
          name: orderCheckout,
          path: 'details',
          builder: (ctx, state) => const OrderCheckoutPage(),
        ),
      ],
    ),
    GoRoute(
      name: history,
      path: 'history',
      parentNavigatorKey: rootNavigatorKey,
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
      parentNavigatorKey: rootNavigatorKey,
      // TODO: use dialog
      builder: (ctx, state) => const ImageGalleryPage(),
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
      return state.uri.path == '${Routes.base}/$prefix/$path' ? '${Routes.base}/$prefix' : null;
    },
    routes: routes,
  );
}

enum HomeMode {
  bottomNavigationBar,
  drawer,
  rail,
}
