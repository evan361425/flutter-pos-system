import 'package:flutter/material.dart';
import 'package:possystem/components/empty_body.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:possystem/ui/menu/widgets/catalog_list.dart';
import 'package:possystem/ui/menu/widgets/menu_search_bar.dart';
import 'package:provider/provider.dart';

class MenuBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // strictly equal to: Provider.of<MenuModel>(context)
    // context.read<T>() === Provider.of<T>(context, listen: false)
    final menu = context.watch<MenuModel>();

    if (menu.isNotReady) {
      return Center(child: CircularProgressIndicator());
    } else if (menu.length == 0) {
      return EmptyBody('menu.empty');
    } else {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            MenuSearchBar(),
            // get sorted catalogs
            CatalogList(menu.catalogList),
          ],
        ),
      );
    }
  }
}
