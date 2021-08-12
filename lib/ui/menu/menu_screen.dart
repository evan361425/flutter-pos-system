import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/menu/menu_tutorial.dart';
import 'package:possystem/ui/menu/widgets/catalog_list.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with RouteAware, TutorialAware<MenuScreen> {
  final floatingButtonKey = GlobalKey();

  final firstCatalogKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // context.watch<T>() === Provider.of<T>(context, listen: true)
    final menu = context.watch<Menu>();

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
        key: floatingButtonKey,
        onPressed: navigateNewCatalog,
        tooltip: tt('menu.catalog.add'),
        child: Icon(KIcons.add),
      ),
      body: menu.isEmpty
          ? Center(child: EmptyBody(onPressed: navigateNewCatalog))
          : _body(menu),
    );
  }

  void navigateNewCatalog() {
    Navigator.of(context).pushNamed(Routes.menuCatalogModal);
  }

  @override
  bool showTutorialIfNeed() {
    if (Menu.instance.isEmpty) return false;
    final steps =
        Cache.instance.neededTutorial('menu.basic', MenuTutorial.STEPS);

    if (steps.isNotEmpty) {
      showTutorial(() => MenuTutorial.build(
            context,
            steps,
            firstCatalog: firstCatalogKey,
            addButton: floatingButtonKey,
          ));
    }
    return steps.isEmpty;
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

  Widget _body(Menu menu) {
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
    final catalogList = CatalogList(menu.itemList, firstKey: firstCatalogKey);

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
