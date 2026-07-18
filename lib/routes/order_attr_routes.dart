import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/order_attr/order_attribute_page.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_modal.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_option_modal.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_option_reorder.dart';
import 'package:possystem/ui/order_attr/widgets/order_attribute_reorder.dart';

/// Order attribute feature routes.
List<RouteBase> orderAttrRoutes = [
  GoRoute(
    name: AppRouteNames.orderAttributes,
    path: AppRouteNames.orderAttributes,
    pageBuilder: (ctx, state) =>
        NoTransitionPage(child: _l(const OrderAttributePage(), state)),
    routes: [
      _createPrefixRoute(
        path: 'attr',
        prefix: 'oa',
        routes: [
          GoRoute(
            name: AppRouteNames.orderAttributeCreate,
            path: 'create',
            parentNavigatorKey: Routes.rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(
              child: _l(const OrderAttributeModal(), state),
            ),
          ),
          GoRoute(
            path: 'a/:id',
            parentNavigatorKey: Routes.rootNavigatorKey,
            redirect: _redirectIfMissed(
              path: 'oa',
              hasItem: (id) => OrderAttributes.instance.hasItem(id),
            ),
            routes: [
              GoRoute(
                name: AppRouteNames.orderAttributeUpdate,
                path: 'update',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final attr = OrderAttributes.instance.getItem(
                    state.pathParameters['id']!,
                  )!;
                  return MaterialDialogPage(
                    child: _l(OrderAttributeModal(attribute: attr), state),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            name: AppRouteNames.orderAttributeReorder,
            path: 'reorder',
            parentNavigatorKey: Routes.rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(
              child: _l(const OrderAttributeReorder(), state),
            ),
          ),
          GoRoute(
            name: AppRouteNames.orderAttributeReorderOption,
            path: 'reorder/option',
            parentNavigatorKey: Routes.rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(
              child: _l(const OrderAttributeOptionReorder(), state),
            ),
          ),
          GoRoute(
            name: AppRouteNames.orderAttributeUpdateOption,
            path: 'update/option',
            parentNavigatorKey: Routes.rootNavigatorKey,
            pageBuilder: (ctx, state) => MaterialDialogPage(
              child: _l(const OrderAttributeOptionModal(), state),
            ),
          ),
        ],
      ),
    ],
  ),
];
