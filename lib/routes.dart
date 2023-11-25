import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:possystem/ui/analysis/history_page.dart';
import 'package:possystem/ui/stock/widgets/replenishment_apply.dart';

import 'models/repository/menu.dart';
import 'models/repository/order_attributes.dart';
import 'models/repository/quantities.dart';
import 'models/repository/replenisher.dart';
import 'models/repository/stock.dart';
import 'ui/analysis/widgets/history_order_modal.dart';
import 'ui/cashier/changer_page.dart';
import 'ui/cashier/surplus_page.dart';
import 'ui/home/feature_request_page.dart';
import 'ui/home/features_page.dart';
import 'ui/home/home_page.dart';
import 'ui/image_gallery_page.dart';
import 'ui/menu/menu_page.dart';
import 'ui/menu/product_page.dart';
import 'ui/menu/widgets/product_ingredient_modal.dart';
import 'ui/menu/widgets/product_quantity_modal.dart';
import 'ui/menu/widgets/catalog_modal.dart';
import 'ui/menu/widgets/catalog_reorder.dart';
import 'ui/menu/widgets/product_modal.dart';
import 'ui/menu/widgets/product_reorder.dart';
import 'ui/order/cashier/order_details_page.dart';
import 'ui/order/order_page.dart';
import 'ui/order_attr/order_attribute_page.dart';
import 'ui/order_attr/widgets/order_attribute_modal.dart';
import 'ui/order_attr/widgets/order_attribute_option_modal.dart';
import 'ui/order_attr/widgets/order_attribute_option_reorder.dart';
import 'ui/order_attr/widgets/order_attribute_reorder.dart';
import 'ui/stock/quantity_page.dart';
import 'ui/stock/widgets/stock_quantity_modal.dart';
import 'ui/stock/widgets/stock_ingredient_modal.dart';
import 'ui/stock/widgets/replenishment_modal.dart';
import 'ui/stock/replenishment_page.dart';
import 'ui/transit/transit_page.dart';
import 'ui/transit/transit_station.dart';

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
    return id == null || !hasItem(id) ? ctx.namedLocation(path) : null;
  };
}

class Routes {
  static const base = '/pos';

  static final home = GoRoute(
    name: 'home',
    path: base,
    builder: (ctx, state) {
      final tab = _findEnum(
        HomeTab.values,
        state.uri.queryParameters['tab'],
        Menu.instance.isEmpty ? HomeTab.setting : HomeTab.analysis,
      );
      return HomePage(tab: tab);
    },
    routes: routes,
  );

  static final routes = [
    _menuRoute,
    _stockRoute,
    _orderAttrRoute,
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
      path: 'history/o',
      builder: (ctx, state) => const HistoryPage(),
    ),
    GoRoute(
      name: historyModal,
      path: 'history/o/:id/modal',
      builder: (ctx, state) => HistoryOrderModal(
        int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
      ),
    ),
    GoRoute(
      name: cashierChanger,
      path: 'cashier/changer',
      builder: (ctx, state) => const ChangerModal(),
    ),
    GoRoute(
      name: cashierSurplus,
      path: 'cashier/surplus',
      builder: (ctx, state) => const CashierSurplus(),
    ),
    GoRoute(
      name: transit,
      path: 'transit',
      builder: (ctx, state) => TransitPage(),
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
              TransitType.values,
              state.pathParameters['type'],
              TransitType.basic,
            );
            final range = _parseRange(state.uri.queryParameters['range']);

            return TransitStation(
              method: method,
              type: type,
              range: range,
            );
          },
        ),
      ],
    ),
    GoRoute(
      name: featureRequest,
      path: 'feature_request',
      builder: (ctx, state) => const FeatureRequestPage(),
    ),
    GoRoute(
      name: imageGallery,
      path: 'image_gallery',
      builder: (ctx, state) => const ImageGalleryPage(),
    ),
    GoRoute(
      name: features,
      path: 'features',
      builder: (ctx, state) => const FeaturesPage(),
    ),
  ];

  static final _menuRoute = GoRoute(
    name: menu,
    path: 'menu',
    builder: (ctx, state) {
      final id = state.uri.queryParameters['id'];
      final mode = state.uri.queryParameters['mode'];
      final catalog = id != null ? Menu.instance.getItem(id) : null;
      return MenuPage(
        catalog: catalog,
        productOnly: mode == 'products',
      );
    },
    routes: [
      GoRoute(
        name: menuNew,
        path: 'new',
        builder: (ctx, state) {
          final id = state.uri.queryParameters['id'];
          final c = id == null ? null : Menu.instance.getItem(id);

          if (c == null) {
            return const CatalogModal();
          }
          return ProductModal(catalog: c);
        },
      ),
      GoRoute(
        name: menuReorder,
        path: 'reorder',
        builder: (ctx, state) => const CatalogReorder(),
      ),
      GoRoute(
        name: menuCatalogModal,
        path: 'c/:id/modal',
        builder: (ctx, state) => CatalogModal(
          catalog: Menu.instance.getItem(state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        name: menuCatalogReorder,
        path: 'c/:id/reorder',
        redirect: _redirectIfMissed(
          path: menu,
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
          path: menu,
          hasItem: (id) => Menu.instance.getProduct(id) != null,
        ),
        builder: (ctx, state) => ProductPage(
          product: Menu.instance.getProduct(state.pathParameters['id']!)!,
        ),
        routes: [
          GoRoute(
            name: menuProductModal,
            path: 'modal',
            builder: (ctx, state) {
              // verified for parent
              final p = Menu.instance.getProduct(state.pathParameters['id']!)!;
              return ProductModal(product: p, catalog: p.catalog);
            },
          ),
          GoRoute(
            name: menuProductDetails,
            path: 'details',
            builder: (ctx, state) {
              // verified for parent
              final p = Menu.instance.getProduct(state.pathParameters['id']!)!;
              final ing = p.getItem(state.uri.queryParameters['iid'] ?? '');
              final qid = state.uri.queryParameters['qid'];
              if (ing == null || qid == null) {
                return ProductIngredientModal(product: p, ingredient: ing);
              }

              return ProductQuantityModal(
                quantity: ing.getItem(qid),
                ingredient: ing,
              );
            },
          ),
        ],
      ),
    ],
  );

  static final _stockRoute = GoRoute(
    path: 'stock',
    redirect: (ctx, state) => state.path == '$base/stock' ? base : null,
    routes: [
      GoRoute(
        name: ingredientNew,
        path: 'new',
        builder: (ctx, state) => const StockIngredientModal(),
      ),
      GoRoute(
        name: ingredientModal,
        path: 'i/:id/modal',
        builder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return StockIngredientModal(ingredient: Stock.instance.getItem(id));
        },
      ),
      GoRoute(
        name: quantity,
        path: 'quantities',
        builder: (ctx, state) => const QuantityPage(),
        routes: [
          GoRoute(
            name: quantityNew,
            path: 'new',
            builder: (ctx, state) => const StockQuantityModal(),
          ),
          GoRoute(
            name: quantityModal,
            path: 'q/:id/modal',
            builder: (ctx, state) {
              final id = state.pathParameters['id'] ?? '';
              return StockQuantityModal(
                  quantity: Quantities.instance.getItem(id));
            },
          ),
        ],
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
            builder: (ctx, state) {
              final id = state.pathParameters['id'] ?? '';
              return ReplenishmentModal(
                replenishment: Replenisher.instance.getItem(id),
              );
            },
          ),
          GoRoute(
            name: replenishmentApply,
            path: 'r/:id/apply',
            redirect: (context, state) {
              final has = Replenisher.instance
                  .hasItem(state.pathParameters['id'] ?? '');
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

  static final _orderAttrRoute = GoRoute(
    name: orderAttr,
    path: 'oa',
    builder: (ctx, state) => const OrderAttributePage(),
    routes: [
      GoRoute(
        name: orderAttrNew,
        path: 'new',
        builder: (ctx, state) {
          final id = state.uri.queryParameters['id'];
          final oa = id == null ? null : OrderAttributes.instance.getItem(id);

          if (oa == null) {
            return const OrderAttributeModal();
          }
          return OrderAttributeOptionModal(oa);
        },
      ),
      GoRoute(
        name: orderAttrModal,
        path: 'a/:id/modal',
        builder: (ctx, state) {
          final id = state.pathParameters['id'];
          final oid = state.uri.queryParameters['oid'];
          final oa = id == null ? null : OrderAttributes.instance.getItem(id);

          if (oid == null || oa == null) {
            // edit or new oa
            return OrderAttributeModal(attribute: oa);
          }
          return OrderAttributeOptionModal(oa, option: oa.getItem(oid));
        },
      ),
      GoRoute(
        name: orderAttrOptionReorder,
        path: 'a/:id/reorder',
        redirect: _redirectIfMissed(
          path: orderAttr,
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

  static const menu = '/menu';
  static const menuNew = '/menu/new';
  static const menuSearch = '/menu/search';
  static const menuReorder = '/menu/reorder';
  static const menuCatalogModal = '/menu/catalog/modal';
  static const menuCatalogReorder = '/menu/catalog/reorder';
  static const menuProduct = '/menu/product';
  static const menuProductModal = '/menu/product/modal';
  static const menuProductDetails = '/menu/product/details';

  static const history = '/history/order';
  static const historyModal = '/history/order/modal';

  static const orderAttr = '/oa';
  static const orderAttrNew = '/oa/new';
  static const orderAttrModal = '/oa/modal';
  static const orderAttrReorder = '/oa/reorder';
  static const orderAttrOptionReorder = '/oa/option/reorder';

  static const ingredientNew = '/stock/new';
  static const ingredientModal = '/stock/ingredient/modal';
  static const quantity = '/stock/quantities';
  static const quantityNew = '/stock/quantity/new';
  static const quantityModal = '/stock/quantity/modal';
  static const replenishment = '/stock/repl';
  static const replenishmentNew = '/stock/repl/new';
  static const replenishmentModal = '/stock/repl/modal';
  static const replenishmentApply = '/stock/repl/apply';

  static const cashierChanger = '/cashier/changer';
  static const cashierSurplus = '/cashier/surplus';

  static const order = '/order';
  static const orderDetails = '/order/details';

  static const transit = '/transit';
  static const transitStation = '/transit/station';

  static const featureRequest = '/feature_request';
  static const imageGallery = '/image_gallery';
  static const features = '/features';
}
