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

    final navigateNewCatalog =
        () => Navigator.of(context).pushNamed(Routes.menuCatalogModal);

    final body = menu.isReady
        ? menu.isEmpty
            ? Center(child: EmptyBody(onPressed: navigateNewCatalog))
            : _body(context, menu)
        : CircularLoading();

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
              actions: _actions(),
            ),
            icon: Icon(KIcons.more),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateNewCatalog,
        tooltip: tt('menu.catalog.add'),
        child: Icon(KIcons.add),
      ),
      body: body,
    );
  }

  List<BottomSheetAction> _actions() {
    return <BottomSheetAction>[
      BottomSheetAction(
        title: Text(tt('menu.catalog.order')),
        leading: Icon(Icons.reorder_sharp),
        onTap: (context) {
          Navigator.of(context).pushReplacementNamed(Routes.menuCatalogReorder);
        },
      ),
    ];
  }

  Widget _body(BuildContext context, Menu menu) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kSpacing1),
          child: Text(
            tt('total_count', {'count': menu.length}),
            style: Theme.of(context).textTheme.muted,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // get sorted catalogs
                CatalogList(menu.itemList),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
