import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/catalog_list.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // context.watch<T>() === Provider.of<T>(context, listen: true)
    final menu = context.watch<Menu>();

    goAddCatalog() => Navigator.of(context).pushNamed(Routes.menuCatalogModal);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.menuTitle),
        leading: const PopButton(),
        actions: [
          IconButton(
            key: const Key('menu.more'),
            onPressed: () => _showActions(context),
            enableFeedback: true,
            icon: const Icon(KIcons.more),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('menu.add'),
        onPressed: goAddCatalog,
        tooltip: S.menuCatalogCreate,
        child: const Icon(KIcons.add),
      ),
      body: menu.isEmpty
          ? Center(
              child: EmptyBody(
              tooltip: '我們會把相似「產品」放在「產品種類」中，\n到時候點餐會比較方便。\n'
                  '例如：\n'
                  '「起司漢堡」、「蔬菜漢堡」整合進「漢堡」\n'
                  '「塑膠袋」、「環保杯」整合進「其他」',
              onPressed: goAddCatalog,
            ))
          : _MenuBody(menu),
    );
  }

  void _showActions(BuildContext context) {
    showCircularBottomSheet(
      context,
      actions: <BottomSheetAction<void>>[
        BottomSheetAction(
          title: Text(S.menuCatalogReorder),
          leading: const Icon(Icons.reorder_sharp),
          navigateRoute: Routes.menuCatalogReorder,
        ),
      ],
    );
  }
}

class _MenuBody extends StatelessWidget {
  final Menu menu;

  const _MenuBody(this.menu);

  @override
  Widget build(BuildContext context) {
    final searchBar = Padding(
      padding: const EdgeInsets.fromLTRB(kSpacing1, kSpacing1, kSpacing1, 0),
      child: SearchBarInline(
        key: const Key('menu.search'),
        hintText: S.menuSearchProductHint,
        onTap: (context) => Navigator.of(context).pushNamed(Routes.menuSearch),
      ),
    );

    return Column(
      children: [
        searchBar,
        Expanded(child: CatalogList(menu.itemList)),
      ],
    );
  }
}
