import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/ui/analysis/analysis_view.dart';
import 'package:possystem/ui/analysis/history_page.dart';
import 'package:possystem/ui/analysis/widgets/chart_modal.dart';
import 'package:possystem/ui/analysis/widgets/chart_reorder.dart';
import 'package:possystem/ui/analysis/widgets/history_order_modal.dart';
import 'package:possystem/ui/cashier/cashier_view.dart';
import 'package:possystem/ui/cashier/changer_modal.dart';
import 'package:possystem/ui/cashier/surplus_page.dart';
import 'package:possystem/ui/home/feature_request_page.dart';
import 'package:possystem/ui/home/features_page.dart';
import 'package:possystem/ui/home/home_page.dart';
import 'package:possystem/ui/home/mobile_entry_view.dart';
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
import 'package:possystem/ui/stock/quantity_page.dart';
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

class Routes {
  static const base = '/pos';

  static final ValueNotifier<HomeMode> homeMode = ValueNotifier(HomeMode.bottomNavigationBar);

  static getRoute(String path) => 'https://evan361425.github.io$base/$path';

  static FutureOr<String?> redirect(BuildContext ctx, GoRouterState state) =>
      state.path?.startsWith(Routes.base) == false ? Routes.base : null;

  static RoutingConfig getDesiredRoute(double width) {
    switch (Breakpoint.find(width: width)) {
      case Breakpoint.compact:
      case Breakpoint.medium:
        homeMode.value = HomeMode.bottomNavigationBar;
        return Routes.bottomNav;
      case Breakpoint.expanded:
      case Breakpoint.large:
        homeMode.value = HomeMode.drawer;
        return Routes.drawer;
      case Breakpoint.extraLarge:
        homeMode.value = HomeMode.rail;
        return Routes.rail;
    }
  }

  // Stateful navigation based on:
  // https://codewithandrea.com/articles/flutter-bottom-navigation-bar-nested-routes-gorouter/
  static final RoutingConfig bottomNav = RoutingConfig(redirect: Routes.redirect, routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => HomePage(shell: shell, mode: homeMode),
      // the order of this list should follow the order of the tabs
      branches: [
        StatefulShellBranch(routes: [_analysisRoute]),
        StatefulShellBranch(routes: [_stockRoute]),
        StatefulShellBranch(routes: [_cashierRoute]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '$base/others',
            builder: (ctx, state) => const MobileEntryView(),
          )
        ]),
      ],
    ),
    ..._others,
  ]);

  static final RoutingConfig drawer = RoutingConfig(redirect: Routes.redirect, routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => HomePage(shell: shell, mode: homeMode),
      branches: [
        StatefulShellBranch(routes: [_analysisRoute]),
        StatefulShellBranch(routes: [_stockRoute]),
        StatefulShellBranch(routes: [_cashierRoute]),
        StatefulShellBranch(routes: [_orderAttrRoute]),
        StatefulShellBranch(routes: [_menuRoute]),
        StatefulShellBranch(routes: [_quantitiesRoute]),
        StatefulShellBranch(routes: [_transitRoute]),
        StatefulShellBranch(routes: [_elfRoute]),
        StatefulShellBranch(routes: [_settingsRoute]),
      ],
    ),
    ..._others,
  ]);

  static final RoutingConfig rail = drawer;

  static final _others = [
    GoRoute(
      name: order,
      path: '$base/order',
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
      path: '$base/history/o',
      builder: (ctx, state) => const HistoryPage(),
    ),
    GoRoute(
      name: historyModal,
      path: '$base/history/o/:id/modal',
      pageBuilder: (ctx, state) => MaterialDialogPage(
        child: HistoryOrderModal(int.tryParse(state.pathParameters['id'] ?? '0') ?? 0),
      ),
    ),
    GoRoute(
      name: imageGallery,
      path: '$base/image_gallery',
      // TODO: use dialog
      builder: (ctx, state) => const ImageGalleryPage(),
    ),
  ];

  static final _analysisRoute = GoRoute(
    name: anal,
    path: base,
    pageBuilder: (ctx, state) => const NoTransitionPage(child: AnalysisView()),
    routes: [
      GoRoute(
        name: chartNew,
        path: 'chart/new',
        pageBuilder: (ctx, state) => const MaterialDialogPage(child: ChartModal()),
      ),
      GoRoute(
        name: chartModal,
        path: 'chart/o/:id/modal',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id']!;
          final chart = Analysis.instance.getItem(id);
          return MaterialDialogPage(child: ChartModal(chart: chart));
        },
      ),
      GoRoute(
        name: chartReorder,
        path: 'chart/reorder',
        builder: (ctx, state) => const ChartReorder(),
      ),
    ],
  );

  static final _stockRoute = GoRoute(
    name: stock,
    path: '$base/stock',
    pageBuilder: (ctx, state) {
      return const NoTransitionPage(child: StockView());
    },
    routes: [
      GoRoute(
        name: ingredientNew,
        path: 'new',
        pageBuilder: (ctx, state) => const MaterialDialogPage(child: StockIngredientModal()),
      ),
      GoRoute(
        name: ingredientModal,
        path: 'i/:id/modal',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialDialogPage(child: StockIngredientModal(ingredient: Stock.instance.getItem(id)));
        },
      ),
      GoRoute(
        name: ingredientRestockModal,
        path: 'i/:id/restock',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialDialogPage(child: StockIngredientRestockModal(ingredient: Stock.instance.getItem(id)));
        },
      ),
      GoRoute(
        name: replenishment,
        path: 'repl',
        builder: (ctx, state) => const ReplenishmentPage(),
        routes: [
          GoRoute(
            name: replenishmentNew,
            path: 'new',
            builder: (ctx, state) => const ReplenishmentModal(),
          ),
          GoRoute(
            name: replenishmentModal,
            path: 'r/:id/modal',
            pageBuilder: (ctx, state) {
              final id = state.pathParameters['id'] ?? '';
              return MaterialDialogPage(
                child: ReplenishmentModal(replenishment: Replenisher.instance.getItem(id)),
              );
            },
          ),
          GoRoute(
            name: replenishmentApply,
            path: 'r/:id/apply',
            redirect: (context, state) {
              final has = Replenisher.instance.hasItem(state.pathParameters['id'] ?? '');
              return has ? null : '$base/stock/repl';
            },
            builder: (ctx, state) {
              final id = state.pathParameters['id'] ?? '';
              return ReplenishmentApply(Replenisher.instance.getItem(id)!);
            },
          ),
        ],
      ),
    ],
  );

  static final _cashierRoute = GoRoute(
    name: cashier,
    path: '$base/cashier',
    pageBuilder: (ctx, state) {
      return const NoTransitionPage(child: CashierView());
    },
    routes: [
      GoRoute(
        name: cashierChanger,
        path: 'changer',
        pageBuilder: (ctx, state) => const MaterialDialogPage(child: ChangerModal()),
      ),
      GoRoute(
        name: cashierSurplus,
        path: 'surplus',
        builder: (ctx, state) => const CashierSurplus(),
      )
    ],
  );

  static final _menuRoute = GoRoute(
    name: menu,
    path: '$base/menu',
    builder: (ctx, state) {
      final id = state.uri.queryParameters['id'];
      final mode = state.uri.queryParameters['mode'];
      final catalog = id != null ? Menu.instance.getItem(id) : null;
      return MenuPage(
        catalog: catalog,
        productOnly: mode == 'products',
        withScaffold: state.extra == 'withScaffold',
      );
    },
    routes: [
      GoRoute(
        name: menuNew,
        path: 'new',
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
        name: menuCatalogModal,
        path: 'c/:id/modal',
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
      GoRoute(
        name: menuProductReorder,
        path: 'c/:id/reorder',
        redirect: _redirectIfMissed(
          path: '/menu',
          hasItem: (id) => Menu.instance.hasItem(id),
        ),
        builder: (ctx, state) => ProductReorder(
          Menu.instance.getItem(state.pathParameters['id']!)!,
        ),
      ),
      GoRoute(
        name: menuProduct,
        path: 'p/:id',
        redirect: _redirectIfMissed(
          path: '/menu',
          hasItem: (id) => Menu.instance.getProduct(id) != null,
        ),
        builder: (ctx, state) => ProductPage(
          product: Menu.instance.getProduct(state.pathParameters['id']!)!,
        ),
        routes: [
          GoRoute(
            name: menuProductModal,
            path: 'modal',
            pageBuilder: (ctx, state) {
              // verified for parent
              final p = Menu.instance.getProduct(state.pathParameters['id']!)!;
              return MaterialDialogPage(child: ProductModal(product: p, catalog: p.catalog));
            },
          ),
          GoRoute(
            name: menuProductDetails,
            path: 'details',
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
            name: menuIngredientReorder,
            path: 'reorder',
            redirect: _redirectIfMissed(
              path: '/menu',
              hasItem: (id) => Menu.instance.getProduct(id) != null,
            ),
            builder: (ctx, state) => ProductIngredientReorder(
              Menu.instance.getProduct(state.pathParameters['id']!)!,
            ),
          ),
        ],
      ),
    ],
  );

  static final _quantitiesRoute = GoRoute(
    name: quantity,
    path: '$base/quantities',
    builder: (ctx, state) => QuantityPage(withScaffold: state.extra == 'withScaffold'),
    routes: [
      GoRoute(
        name: quantityNew,
        path: 'new',
        builder: (ctx, state) => const StockQuantityModal(),
      ),
      GoRoute(
        name: quantityModal,
        path: 'q/:id/modal',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialDialogPage(
            child: StockQuantityModal(quantity: Quantities.instance.getItem(id)),
          );
        },
      ),
    ],
  );

  static final _orderAttrRoute = GoRoute(
    name: orderAttr,
    path: '$base/oa',
    builder: (ctx, state) => OrderAttributePage(withScaffold: state.extra == 'withScaffold'),
    routes: [
      GoRoute(
        name: orderAttrNew,
        path: 'new',
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
        name: orderAttrModal,
        path: 'a/:id/modal',
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
        name: orderAttrOptionReorder,
        path: 'a/:id/reorder',
        redirect: _redirectIfMissed(
          path: '/oa',
          hasItem: (id) => OrderAttributes.instance.hasItem(id),
        ),
        builder: (ctx, state) {
          return OrderAttributeOptionReorder(
            attribute: OrderAttributes.instance.getItem(
              state.pathParameters['id']!,
            )!,
          );
        },
      ),
      GoRoute(
        name: orderAttrReorder,
        path: 'reorder',
        builder: (ctx, state) => const OrderAttributeReorder(),
      ),
    ],
  );

  static final _transitRoute = GoRoute(
    name: transit,
    path: '$base/transit',
    builder: (ctx, state) => TransitPage(withScaffold: state.extra == 'withScaffold'),
    routes: [
      GoRoute(
        name: transitStation,
        path: 's/:method/:type',
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
    path: '$base/elf',
    builder: (ctx, state) => FeatureRequestPage(withScaffold: state.extra == 'withScaffold'),
  );

  static final _settingsRoute = GoRoute(
    name: settings,
    path: '$base/settings',
    builder: (ctx, state) => FeaturesPage(
      focus: state.uri.queryParameters['f'],
      withScaffold: state.extra == 'withScaffold',
    ),
    routes: [
      GoRoute(
        name: settingsChoices,
        path: ':feature',
        builder: (ctx, state) {
          final f = state.pathParameters['feature'];
          final feature = Feature.values.firstWhereOrNull((e) => e.name == f) ?? Feature.theme;
          return ItemListScaffold(feature: feature);
        },
      ),
    ],
  );

  static const menu = '/menu';
  static const menuNew = '/menu/new';
  static const menuSearch = '/menu/search';
  static const menuCatalogModal = '/menu/catalog/modal';
  static const menuCatalogReorder = '/menu/catalog/reorder';
  static const menuProduct = '/menu/product';
  static const menuProductModal = '/menu/product/modal';
  static const menuProductReorder = '/menu/product/reorder';
  static const menuProductDetails = '/menu/product/details';
  static const menuIngredientReorder = '/menu/ingredient/reorder';

  static const history = '/history/order';
  static const historyModal = '/history/order/modal';

  static const orderAttr = '/oa';
  static const orderAttrNew = '/oa/new';
  static const orderAttrModal = '/oa/modal';
  static const orderAttrReorder = '/oa/reorder';
  static const orderAttrOptionReorder = '/oa/option/reorder';

  static const stock = '/stock';
  static const ingredientNew = '/stock/new';
  static const ingredientModal = '/stock/ingredient/modal';
  static const ingredientRestockModal = '/stock/ingredient/restock/modal';
  static const quantity = '/stock/quantities';
  static const quantityNew = '/stock/quantity/new';
  static const quantityModal = '/stock/quantity/modal';
  static const replenishment = '/stock/repl';
  static const replenishmentNew = '/stock/repl/new';
  static const replenishmentModal = '/stock/repl/modal';
  static const replenishmentApply = '/stock/repl/apply';

  static const cashier = '/cashier';
  static const cashierChanger = '/cashier/changer';
  static const cashierSurplus = '/cashier/surplus';

  static const order = '/order';
  static const orderDetails = '/order/details';

  static const anal = '/anal';
  static const chartNew = '/chart/order/new';
  static const chartModal = '/chart/order/modal';
  static const chartReorder = '/chart/reorder';

  static const transit = '/transit';
  static const transitStation = '/transit/station';

  static const elf = '/elf';
  static const imageGallery = '/image_gallery';
  static const settings = '/settings';
  static const settingsChoices = '/settings/choices';
}
