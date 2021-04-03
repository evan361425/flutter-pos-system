import 'package:flutter/material.dart';
import 'package:possystem/components/empty_body.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/ui/menu/widgets/catalog_list.dart';
import 'package:provider/provider.dart';

class MenuBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // strictly equal to: Provider.of<MenuModel>(context)
    // context.read<T>() === Provider.of<T>(context, listen: false)
    final menu = context.watch<MenuModel>();

    if (menu.isNotReady) {
      return Center(child: CircularProgressIndicator());
    } else if (menu.isEmpty) {
      return Center(child: EmptyBody('menu.empty'));
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: kPadding / 2),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // TODO: search bar
              // MenuSearchBar(),
              // get sorted catalogs
              CatalogList(menu.catalogList),
            ],
          ),
        ),
      );
    }
  }
}
