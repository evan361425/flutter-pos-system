import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/printer/printer_modal.dart';
import 'package:possystem/ui/printer/printer_page.dart';
import 'package:possystem/ui/printer/printer_settings_modal.dart';

/// Printer feature routes.
List<RouteBase> printerRoutes = [
  GoRoute(
    name: AppRouteNames.printer,
    path: AppRouteNames.printer,
    pageBuilder: (ctx, state) => _l(const PrinterPage(), state),
    routes: [
      GoRoute(
        name: AppRouteNames.printerCreate,
        path: 'create',
        parentNavigatorKey: Routes.rootNavigatorKey,
        pageBuilder: (ctx, state) =>
            MaterialDialogPage(child: _l(const PrinterModal(), state)),
      ),
      GoRoute(
        name: AppRouteNames.printerSettings,
        path: 'settings',
        parentNavigatorKey: Routes.rootNavigatorKey,
        pageBuilder: (ctx, state) =>
            MaterialDialogPage(child: _l(const PrinterSettingsModal(), state)),
      ),
      GoRoute(
        name: AppRouteNames.printerUpdate,
        path: 'update',
        parentNavigatorKey: Routes.rootNavigatorKey,
        pageBuilder: (ctx, state) =>
            MaterialDialogPage(child: _l(const PrinterModal(), state)),
      ),
    ],
  ),
];
