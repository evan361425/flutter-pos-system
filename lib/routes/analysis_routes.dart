import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/analysis/analysis_view.dart';
import 'package:possystem/ui/analysis/history_page.dart';
import 'package:possystem/ui/analysis/widgets/chart_modal.dart';
import 'package:possystem/ui/analysis/widgets/chart_reorder.dart';
import 'package:possystem/ui/analysis/widgets/history_order_modal.dart';

/// Analysis feature routes.
List<RouteBase> analysisRoutes = [
  GoRoute(
    name: AppRouteNames.analytics,
    path: AppRouteNames.analytics,
    pageBuilder: (ctx, state) =>
        NoTransitionPage(child: _l(const AnalysisView(), state)),
    routes: [
      _createPrefixRoute(
        path: 'chart',
        prefix: 'anal',
        routes: [
          GoRoute(
            name: AppRouteNames.analyticsChartCreate,
            path: 'create',
            parentNavigatorKey: Routes.rootNavigatorKey,
            pageBuilder: (ctx, state) =>
                MaterialDialogPage(child: _l(const ChartModal(), state)),
          ),
          GoRoute(
            path: 'a/:id',
            parentNavigatorKey: Routes.rootNavigatorKey,
            redirect: _redirectIfMissed(
              path: 'anal',
              hasItem: (id) => Analysis.instance.hasItem(id),
            ),
            routes: [
              GoRoute(
                name: AppRouteNames.analyticsChartUpdate,
                path: 'update',
                parentNavigatorKey: Routes.rootNavigatorKey,
                pageBuilder: (ctx, state) {
                  final chart = Analysis.instance.getItem(
                    state.pathParameters['id']!,
                  )!;
                  return MaterialDialogPage(
                    child: _l(ChartModal(chart: chart), state),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            name: AppRouteNames.analyticsChartReorder,
            path: 'reorder',
            parentNavigatorKey: Routes.rootNavigatorKey,
            pageBuilder: (ctx, state) =>
                MaterialDialogPage(child: _l(const ChartReorder(), state)),
          ),
        ],
      ),
    ],
  ),
];
