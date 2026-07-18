import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/cashier/cashier_view.dart';
import 'package:possystem/ui/cashier/changer_modal.dart';
import 'package:possystem/ui/cashier/surplus_page.dart';

/// Cashier feature routes.
List<RouteBase> cashierRoutes = [
  GoRoute(
    name: AppRouteNames.cashier,
    path: AppRouteNames.cashier,
    pageBuilder: (ctx, state) => _l(const CashierView(), state),
    routes: [
      GoRoute(
        name: AppRouteNames.cashierChanger,
        path: 'changer',
        parentNavigatorKey: Routes.rootNavigatorKey,
        pageBuilder: (ctx, state) =>
            MaterialDialogPage(child: _l(const ChangerModal(), state)),
      ),
      GoRoute(
        name: AppRouteNames.cashierSurplus,
        path: 'surplus',
        pageBuilder: (ctx, state) => _l(const SurplusPage(), state),
      ),
    ],
  ),
];
