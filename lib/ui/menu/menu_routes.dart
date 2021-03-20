import 'package:flutter/cupertino.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:provider/provider.dart';

import 'widgets/catalog_orderable_list.dart';

class MenuRoutes {
  static PageRoute reorderCatalog() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        final items = context.watch<MenuModel>().catalogList;
        return CatalogOrderableList(items: items);
      },
    );
  }
}
