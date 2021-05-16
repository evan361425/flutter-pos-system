import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/empty_body.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/ui/menu/widgets/catalog_list.dart';
import 'package:provider/provider.dart';

import 'menu_actions.dart';

class MenuBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // strictly equal to: Provider.of<MenuModel>(context)
    // context.read<T>() === Provider.of<T>(context, listen: false)
    final menu = context.watch<MenuModel>();

    if (menu.isEmpty) return Center(child: EmptyBody('menu.empty'));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kPadding / 2),
          child: Text(
            '共 ${menu.length} 項',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        Expanded(child: _catalogList(menu)),
      ],
    );
  }

  SingleChildScrollView _catalogList(MenuModel menu) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // TODO: search bar
          // MenuSearchBar(),
          // get sorted catalogs
          CatalogList(menu.catalogList),
        ],
      ),
    );
  }
}
