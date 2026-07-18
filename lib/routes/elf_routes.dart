import 'package:go_router/go_router.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/home/elf_page.dart';

/// ELF feature routes.
List<RouteBase> elfRoutes = [
  GoRoute(
    name: AppRouteNames.elf,
    path: AppRouteNames.elf,
    pageBuilder: (ctx, state) => _l(const ElfPage(), state),
  ),
];
