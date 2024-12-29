import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
      redirect: _redirect,
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
                path: '_',
                builder: (ctx, state) => _l(const MobileMoreView(), state),
                routes: [
                  if (!isProd) _debugRoute(inShell: false),
                  _menuRoute(inShell: false),
                  _printerRoute(inShell: false),
                  _quantitiesRoute(inShell: false),
                  _orderAttrsRoute(inShell: false),
                  _elfRoute(inShell: false),
                  _transitRoute(inShell: false),
                  _settingsRoute(inShell: false),
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
      redirect: _redirect,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => HomePage(shell: shell, mode: homeMode),
          branches: [
            StatefulShellBranch(routes: [_analysisRoute]),
            StatefulShellBranch(routes: [_stockRoute]),
            StatefulShellBranch(routes: [_cashierRoute]),
            StatefulShellBranch(routes: [_orderAttrsRoute(inShell: true)]),
            StatefulShellBranch(routes: [_menuRoute(inShell: true)]),
            StatefulShellBranch(routes: [_printerRoute(inShell: true)]),
            StatefulShellBranch(routes: [_quantitiesRoute(inShell: true)]),
            StatefulShellBranch(routes: [_transitRoute(inShell: true)]),
            StatefulShellBranch(routes: [_elfRoute(inShell: true)]),
            StatefulShellBranch(routes: [_settingsRoute(inShell: true)]),
            if (!isProd) StatefulShellBranch(routes: [_debugRoute(inShell: true)]),
            StatefulShellBranch(routes: [
              // This is fallback route for `_` which is the mobile more view
              GoRoute(name: '_anal', path: '_', pageBuilder: _analBuilder),
            ]),
          ],
        ),
        ..._routes,
      ],
    ),
  ]);

  // ==================== Routes in main navigation ====================

  static Page<dynamic> _analBuilder(BuildContext ctx, GoRouterState state) =>
      NoTransitionPage(child: _l(const AnalysisView(), state));
  static final _analysisRoute = GoRoute(
    name: anal,
    path: 'anal',
    pageBuilder: _analBuilder,
    routes: [
      _createPrefixRoute(path: 'chart', prefix: 'anal', routes: [
        GoRoute(
          name: chartCreate,
          path: 'create',
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const ChartModal(), state)),
        ),
        GoRoute(
          name: chartReorder,
          path: 'reorder',
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const ChartReorder(), state)),
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
                return MaterialDialogPage(child: _l(ChartModal(chart: chart), state));
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
    pageBuilder: (ctx, state) => NoTransitionPage(child: _l(const StockView(), state)),
    routes: [
      _createPrefixRoute(path: 'ingr', prefix: 'stock', routes: [
        GoRoute(
          name: stockIngrCreate,
          path: 'create',
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const StockIngredientModal(), state)),
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
                return MaterialDialogPage(child: _l(StockIngredientModal(ingredient: ingr), state));
              },
            ),
            GoRoute(
              name: stockIngrRestock,
              path: 'restock',
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (ctx, state) {
                final ingr = Stock.instance.getItem(state.pathParameters['id']!)!;
                return MaterialDialogPage(child: _l(StockIngredientRestockModal(ingredient: ingr), state));
              },
            ),
          ],
        ),
      ]),
      GoRoute(
        name: stockRepl,
        path: 'repl',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const ReplenishmentPage(), state)),
        routes: [
          GoRoute(
            name: stockReplCreate,
            path: 'create',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const ReplenishmentModal(), state)),
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
                  return MaterialDialogPage(child: _l(ReplenishmentModal(replenishment: repl), state));
                },
              ),
              GoRoute(
                name: stockReplPreview,
                path: 'preview',
                parentNavigatorKey: rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final repl = Replenisher.instance.getItem(state.pathParameters['id']!)!;
                  return MaterialDialogPage(child: _l(ReplenishmentPreviewPage(repl), state));
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
    pageBuilder: (ctx, state) => NoTransitionPage(child: _l(const CashierView(), state)),
    routes: [
      GoRoute(
        name: cashierChanger,
        path: 'changer',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const ChangerModal(), state)),
      ),
      GoRoute(
        name: cashierSurplus,
        path: 'surplus',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const CashierSurplus(), state)),
      ),
    ],
  );
  static GoRoute _orderAttrsRoute({required bool inShell}) => GoRoute(
        name: orderAttr,
        path: '${(inShell ? '_/' : '')}order_attr',
        parentNavigatorKey: inShell ? null : rootNavigatorKey,
        builder: (ctx, state) => _w(_l(const OrderAttributePage(), state), S.orderAttributeTitle),
        routes: [
          GoRoute(
            name: orderAttrCreate,
            path: 'create',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) {
              final id = state.uri.queryParameters['id'];
              final oa = id == null ? null : OrderAttributes.instance.getItem(id);

              if (oa == null) {
                return MaterialDialogPage(child: _l(const OrderAttributeModal(), state));
              }
              return MaterialDialogPage(child: OrderAttributeOptionModal(oa));
            },
          ),
          GoRoute(
            name: orderAttrReorder,
            path: 'reorder',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const OrderAttributeReorder(), state)),
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

                  final child = oid == null
                      // edit order attr
                      ? OrderAttributeModal(attribute: oa)
                      // edit order attr option
                      : OrderAttributeOptionModal(oa, option: oa.getItem(oid));

                  return MaterialDialogPage(child: _l(child, state));
                },
              ),
              GoRoute(
                name: orderAttrReorderOption,
                path: 'reorder',
                parentNavigatorKey: rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final oa = OrderAttributes.instance.getItem(state.pathParameters['id']!)!;
                  return MaterialDialogPage(child: _l(OrderAttributeOptionReorder(attribute: oa), state));
                },
              ),
            ],
          ),
        ],
      );
  static GoRoute _menuRoute({required bool inShell}) => GoRoute(
        name: menu,
        path: '${(inShell ? '_/' : '')}menu',
        parentNavigatorKey: inShell ? null : rootNavigatorKey,
        builder: (ctx, state) {
          final id = state.uri.queryParameters['id'];
          final mode = state.uri.queryParameters['mode'];
          final catalog = id != null ? Menu.instance.getItem(id) : null;

          return _l(MenuPage(catalog: catalog, productOnly: mode == 'products'), state);
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
                  return MaterialDialogPage(child: _l(const CatalogModal(), state));
                }
                return MaterialDialogPage(child: _l(ProductModal(catalog: c), state));
              },
            ),
            GoRoute(
              name: menuCatalogReorder,
              path: 'reorder',
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const CatalogReorder(), state)),
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
                    return MaterialDialogPage(child: _l(CatalogModal(catalog: catalog), state));
                  },
                ),
                GoRoute(
                  name: menuProductReorder,
                  path: 'reorder',
                  parentNavigatorKey: rootNavigatorKey,
                  pageBuilder: (ctx, state) {
                    final catalog = Menu.instance.getItem(state.pathParameters['id']!)!;
                    return MaterialDialogPage(child: _l(ProductReorder(catalog), state));
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
            pageBuilder: (ctx, state) {
              final product = Menu.instance.getProduct(state.pathParameters['id']!)!;
              return MaterialDialogPage(child: _l(ProductPage(product: product), state));
            },
            routes: [
              GoRoute(
                name: menuProductUpdate,
                path: 'update',
                parentNavigatorKey: rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final product = Menu.instance.getProduct(state.pathParameters['id']!)!;
                  return MaterialDialogPage(child: _l(ProductModal(product: product, catalog: product.catalog), state));
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
                    return MaterialDialogPage(child: _l(ProductIngredientModal(product: p, ingredient: ingr), state));
                  }

                  final qua = ingr.getItem(qid);
                  return MaterialDialogPage(child: _l(ProductQuantityModal(quantity: qua, ingredient: ingr), state));
                },
              ),
              GoRoute(
                name: menuProductReorderIngredient,
                path: 'reorder',
                parentNavigatorKey: rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final ingr = Menu.instance.getProduct(state.pathParameters['id']!)!;
                  return MaterialDialogPage(child: _l(ProductIngredientReorder(ingr), state));
                },
              ),
            ],
          ),
        ],
      );
  static GoRoute _printerRoute({required bool inShell}) => GoRoute(
        name: printer,
        path: '${(inShell ? '_/' : '')}printer',
        parentNavigatorKey: inShell ? null : rootNavigatorKey,
        builder: (ctx, state) => _w(_l(const PrinterPage(), state), S.printerTitle),
        routes: [
          GoRoute(
            name: printerCreate,
            path: 'create',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const PrinterModal(), state)),
          ),
          GoRoute(
            name: printerSettings,
            path: 'settings',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const PrinterSettingsModal(), state)),
          ),
          GoRoute(
            path: 'a/:id',
            parentNavigatorKey: rootNavigatorKey,
            redirect: _redirectIfMissed(path: 'printer', hasItem: (id) => Printers.instance.hasItem(id)),
            routes: [
              GoRoute(
                name: printerUpdate,
                path: 'update',
                parentNavigatorKey: rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final p = Printers.instance.getItem(state.pathParameters['id']!)!;
                  return MaterialDialogPage(child: _l(PrinterModal(printer: p), state));
                },
              ),
            ],
          ),
        ],
      );
  static GoRoute _quantitiesRoute({required bool inShell}) => GoRoute(
        name: quantities,
        path: '${(inShell ? '_/' : '')}quantities',
        parentNavigatorKey: inShell ? null : rootNavigatorKey,
        builder: (ctx, state) => _w(_l(const QuantitiesPage(), state), S.stockQuantityTitle),
        routes: [
          GoRoute(
            name: quantityCreate,
            path: 'create',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const StockQuantityModal(), state)),
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
                  return MaterialDialogPage(child: _l(StockQuantityModal(quantity: qua), state));
                },
              ),
            ],
          ),
        ],
      );
  static GoRoute _transitRoute({required bool inShell}) => GoRoute(
        name: transit,
        path: '${(inShell ? '_/' : '')}transit',
        parentNavigatorKey: inShell ? null : rootNavigatorKey,
        builder: (ctx, state) => _w(_l(const TransitPage(), state), S.transitTitle),
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

              return _l(
                TransitStation(method: method, catalog: type, range: range),
                state,
              );
            },
          ),
        ],
      );
  static GoRoute _elfRoute({required bool inShell}) => GoRoute(
        name: elf,
        path: '${(inShell ? '_/' : '')}elf',
        parentNavigatorKey: inShell ? null : rootNavigatorKey,
        builder: (ctx, state) => _w(_l(const ElfPage(), state), S.settingElfTitle),
      );
  static GoRoute _settingsRoute({required bool inShell}) => GoRoute(
        name: settings,
        path: '${(inShell ? '_/' : '')}settings',
        parentNavigatorKey: inShell ? null : rootNavigatorKey,
        builder: (ctx, state) => _w(
          _l(SettingsPage(focus: state.uri.queryParameters['f']), state),
          S.settingFeatureTitle,
        ),
        routes: [
          GoRoute(
            name: settingsFeature,
            path: ':feature',
            parentNavigatorKey: rootNavigatorKey,
            builder: (ctx, state) {
              final f = state.pathParameters['feature'];
              final feature = Feature.values.firstWhereOrNull((e) => e.name == f) ?? Feature.theme;
              return _l(ItemListScaffold(feature: feature), state);
            },
          ),
        ],
      );
  static GoRoute _debugRoute({required bool inShell}) => GoRoute(
        name: 'debug',
        path: '${(inShell ? '_/' : '')}debug',
        parentNavigatorKey: inShell ? null : rootNavigatorKey,
        builder: (ctx, state) => _l(const DebugPage(), state),
      );

  // ==================== Other routes ====================

  static final _routes = [
    GoRoute(
      name: order,
      path: 'order',
      builder: (ctx, state) => _l(const OrderPage(), state),
      routes: [
        GoRoute(
          name: orderCheckout,
          path: 'details',
          builder: (ctx, state) => _l(const OrderCheckoutPage(), state),
        ),
      ],
    ),
    GoRoute(
      name: history,
      path: 'history',
      builder: (ctx, state) => _l(const HistoryPage(), state),
      routes: [
        GoRoute(
          name: historyOrder,
          path: 'order/:id',
          pageBuilder: (ctx, state) => MaterialDialogPage(
            child: _l(HistoryOrderModal(int.tryParse(state.pathParameters['id'] ?? '0') ?? 0), state),
          ),
        )
      ],
    ),
    GoRoute(
      name: imageGallery,
      path: 'imageGallery',
      pageBuilder: (ctx, state) => MaterialDialogPage(child: _l(const ImageGalleryPage(), state)),
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
      return state.uri.path == '${Routes.base}/$prefix/$path' ? '${Routes.base}/$prefix' : null;
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

enum HomeMode {
  bottomNavigationBar,
  drawer,
  rail;

  bool isMobile() => this == HomeMode.bottomNavigationBar;
}
