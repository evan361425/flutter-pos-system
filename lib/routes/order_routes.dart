import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/order/cart/split_bill_screen.dart';
import 'package:possystem/ui/order/order_checkout_page.dart';
import 'package:possystem/ui/order/order_page.dart';

/// Order feature routes.
List<RouteBase> orderRoutes = [
  GoRoute(
    name: AppRouteNames.order,
    path: AppRouteNames.order,
    pageBuilder: (ctx, state) => _l(const OrderPage(), state),
    routes: [
      GoRoute(
        name: AppRouteNames.orderCheckout,
        path: 'details',
        pageBuilder: (ctx, state) => _l(const OrderCheckoutPage(), state),
      ),
      GoRoute(
        name: AppRouteNames.orderSplitBill,
        path: 'split-bill',
        pageBuilder: (ctx, state) => _l(const SplitBillScreen(), state),
      ),
    ],
  ),
];
