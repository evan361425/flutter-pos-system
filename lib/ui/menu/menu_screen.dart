import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/components/tip/tip_tutorial.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/menu/widgets/catalog_list.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // context.watch<T>() === Provider.of<T>(context, listen: true)
    final menu = context.watch<Menu>();

    final goAddCatalog =
        () => Navigator.of(context).pushNamed(Routes.menuCatalogModal);

    return Scaffold(
      appBar: AppBar(
        title: Text(tt('menu.catalog.title')),
        leading: PopButton(),
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
        onPressed: goAddCatalog,
        tooltip: tt('menu.catalog.add'),
        child: TipTutorial(
          title: '產品種類',
          message: '我們會把相似「產品」放在「產品種類」中，到時候點餐會比較方便。例如：\n'
              '「起司漢堡」、「蔬菜漢堡」整合進「漢堡」\n'
              '「塑膠袋」、「環保杯」整合進「其他」\n'
              '若需要新增產品種類，可以點此按鈕。',
          label: 'menu.catalog',
          disabled: menu.isNotEmpty,
          child: Icon(KIcons.add),
        ),
      ),
      body: menu.isEmpty
          ? Center(child: EmptyBody(onPressed: goAddCatalog))
          : _body(context, menu),
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
    final searchBar = Padding(
      padding: const EdgeInsets.fromLTRB(kSpacing1, kSpacing1, kSpacing1, 0),
      child: SearchBarInline(
        key: Key('menu.search'),
        hintText: '搜尋產品、成份、份量',
        onTap: (context) => Navigator.of(context).pushNamed(Routes.menuSearch),
      ),
    );

    final catalogCount = Padding(
      padding: const EdgeInsets.all(kSpacing1),
      child: Text(
        tt('total_count', {'count': menu.length}),
        style: Theme.of(context).textTheme.muted,
      ),
    );
    // get sorted catalogs
    final catalogList = CatalogList(menu.itemList);

    return Column(
      children: [
        searchBar,
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                catalogCount,
                catalogList,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
