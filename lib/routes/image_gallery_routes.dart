import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/dialog_page.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/routes/routes.dart';
import 'package:possystem/ui/image_gallery_page.dart';

/// Image gallery feature routes.
List<RouteBase> imageGalleryRoutes = [
  GoRoute(
    name: AppRouteNames.imageGallery,
    path: AppRouteNames.imageGallery,
    pageBuilder: (ctx, state) =>
        MaterialDialogPage(child: _l(const ImageGalleryPage(), state)),
  ),
];
