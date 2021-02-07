import 'package:flutter/material.dart';
import 'package:possystem/components/empty_body.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:possystem/ui/menu/widgets/catalog_list.dart';
import 'package:provider/provider.dart';

class MenuBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // strictly equal to: Provider.of<MenuModel>(context)
    // context.read<T>() === Provider.of<T>(context, listen: false)
    final menu = context.watch<MenuModel>();
    final child = _getChild(menu);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(defaultPadding / 2),
          child: Text(
            Local.of(context).t('menu.title'),
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _getChild(MenuModel menu) {
    if (!menu.isReady()) {
      return Center(child: CircularProgressIndicator());
    } else if (menu.length == 0) {
      return EmptyBody('menu.empty');
    } else {
      // get sorted catalogs
      final catalogs = menu.catalogs;
      return CatalogList(catalogs);
    }
  }
}
