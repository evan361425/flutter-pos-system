import 'package:go_router/go_router.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/transit/transit_page.dart';
import 'package:possystem/ui/transit/transit_station.dart';

/// Transit feature routes.
List<RouteBase> transitRoutes = [
  GoRoute(
    name: AppRouteNames.transit,
    path: AppRouteNames.transit,
    pageBuilder: (ctx, state) => _l(const TransitPage(), state),
    routes: [
      GoRoute(
        name: AppRouteNames.transitStation,
        path: ':method/:catalog',
        parentNavigatorKey: Routes.rootNavigatorKey,
        pageBuilder: (ctx, state) {
          final method =
              TransitMethod.values.firstWhereOrNull(
                (e) => e.name == state.pathParameters['method'],
              ) ??
              TransitMethod.plainText;
          final catalog =
              TransitCatalog.values.firstWhereOrNull(
                (e) => e.name == state.pathParameters['catalog'],
              ) ??
              TransitCatalog.exportOrder;
          final range = _parseRange(state.uri.queryParameters['range']);

          return _l(
            TransitStation(method: method, catalog: catalog, range: range),
            state,
          );
        },
      ),
    ],
  ),
];

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
