import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/home/settings_page.dart';

/// Settings feature routes.
List<RouteBase> settingsRoutes = [
  GoRoute(
    name: AppRouteNames.settings,
    path: AppRouteNames.settings,
    pageBuilder: (ctx, state) =>
        _l(SettingsPage(focus: state.uri.queryParameters['f']), state),
    routes: [
      GoRoute(
        name: AppRouteNames.settingsFeature,
        path: ':feature',
        parentNavigatorKey: Routes.rootNavigatorKey,
        pageBuilder: (ctx, state) {
          final f = state.pathParameters['feature'];
          final feature =
              SettingsFeature.values.firstWhereOrNull((e) => e.name == f) ??
              SettingsFeature.theme;
          return _l(ItemListScaffold(feature: feature), state);
        },
      ),
    ],
  ),
];

enum SettingsFeature {
  theme,
  currency,
  language,
  printer,
  cashier,
  stock,
  orderAttributes,
  menu,
  analysis,
  transit,
  elf,
  debug,
}
