import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/analysis/history_page.dart';
import 'package:possystem/ui/analysis/widgets/history_order_modal.dart';

/// History feature routes.
List<RouteBase> historyRoutes = [
  GoRoute(
    name: AppRouteNames.history,
    path: AppRouteNames.history,
    pageBuilder: (ctx, state) => _l(const HistoryPage(), state),
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
];
