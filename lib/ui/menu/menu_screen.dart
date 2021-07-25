import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/widgets/catalog_list.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // strictly equal to: Provider.of<MenuModel>(context)
    // context.read<T>() === Provider.of<T>(context, listen: false)
    final menu = context.watch<Menu>();

    return Scaffold(
      appBar: AppBar(
        title: Text(tt('menu.catalog.title')),
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(KIcons.back)),
        actions: [
          IconButton(
            onPressed: () => showCircularBottomSheet(
              context,
              actions: _actions(context),
            ),
            icon: Icon(KIcons.more),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(Routes.menuCatalogModal),
        tooltip: tt('menu.catalog.add'),
        child: Icon(KIcons.add),
      ),
      // When click android go back, it will avoid closing APP
      body: menu.isReady ? _body(context, menu) : CircularLoading(),
    );
  }

  List<Widget> _actions(BuildContext context) {
    return <Widget>[
      ListTile(
        title: Text(tt('menu.catalog.order')),
        leading: Icon(Icons.reorder_sharp),
        onTap: () => Navigator.of(context)
            .pushReplacementNamed(Routes.menuCatalogReorder),
      ),
    ];
  }

  Widget _body(BuildContext context, Menu menu) {
    if (menu.isEmpty) {
      return Center(child: EmptyBody(body: Text(tt('menu.catalog.empty'))));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kSpacing1),
          child: Text(
            tt('total_count', {'count': menu.length}),
            style: Theme.of(context).textTheme.muted,
          ),
        ),
        Expanded(child: _catalogList(menu)),
      ],
    );
  }

  SingleChildScrollView _catalogList(Menu menu) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // get sorted catalogs
          CatalogList(menu.itemList),
        ],
      ),
    );
  }
}
