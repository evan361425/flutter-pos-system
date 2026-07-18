import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/debug/debug_page.dart';

/// Debug feature routes (only available in non-production).
List<RouteBase> debugRoutes = [
  GoRoute(
    name: AppRouteNames.debug,
    path: AppRouteNames.debug,
    pageBuilder: (ctx, state) => _l(const DebugPage(), state),
  ),
];
