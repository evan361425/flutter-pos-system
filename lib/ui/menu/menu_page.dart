import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/search_bar_wrapper.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/menu_catalog_list.dart';
import 'widgets/menu_product_list.dart';

class MenuPage extends StatefulWidget {
  final Catalog? catalog;

  final bool productOnly;

  const MenuPage({
    Key? key,
    this.catalog,
    this.productOnly = false,
  }) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Catalog? selected;
  late final PageController controller;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(selected?.name ?? S.menuTitle),
          leading: PopButton(
            onPressed: () async {
              if (await _willPop()) {
                if (context.mounted && context.canPop()) {
                  context.pop();
                }
              }
            },
          ),
          actions: [
            if (!widget.productOnly)
              IconButton(
                tooltip: selected == null
                    ? S.menuCatalogReorder
                    : S.menuProductReorder,
                onPressed: () {
                  selected == null
                      ? context.pushNamed(Routes.menuReorder)
                      : context.pushNamed(
                          Routes.menuCatalogReorder,
                          pathParameters: {'id': selected!.id},
                        );
                },
                icon: const Icon(Icons.compare_arrows_sharp),
              ),
            SearchBarWrapper(
              key: const Key('menu.search'),
              hintText: S.menuSearchProductHint,
              initData: Menu.instance.searchProducts(),
              search: (text) async => Menu.instance.searchProducts(text: text),
              itemBuilder: _searchItemBuilder,
              emptyBuilder: _searchEmptyBuilder,
            ),
          ],
        ),
        floatingActionButton: widget.productOnly
            ? null
            : FloatingActionButton(
                key: const Key('menu.add'),
                onPressed: _handleCreate,
                tooltip: S.menuCatalogCreate,
                child: const Icon(KIcons.add),
              ),
        body: PageView(
          controller: controller,
          // disable scrolling, only control by program
          physics: const NeverScrollableScrollPhysics(),
          children: [
            firstView,
            secondView,
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    context.watch<Menu>();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    selected = widget.catalog;
    controller = PageController(
      // go to product if has selected catalog
      initialPage: widget.catalog == null ? 0 : 1,
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget get firstView {
    if (Menu.instance.isEmpty) {
      return Center(
        child: EmptyBody(
          helperText: '我們會把相似「產品」放在「產品種類」中，\n到時候點餐會比較方便，例如：\n'
              '「起司漢堡」、「蔬菜漢堡」整合進「漢堡」\n'
              '「塑膠袋」、「環保杯」整合進「其他」',
          onPressed: _handleCreate,
        ),
      );
    }

    if (widget.productOnly) {
      return const MenuProductList(catalog: null);
    }

    return MenuCatalogList(
      Menu.instance.itemList, // put it here to handle reload
      onSelected: _handleSelected,
    );
  }

  Widget get secondView {
    if (selected?.isNotEmpty == true) {
      return MenuProductList(catalog: selected);
    }

    // empty or not exist
    return Center(
      child: EmptyBody(
        key: const Key('catalog.empty'),
        title: S.menuCatalogEmptyBody,
        helperText: '「產品」是菜單裡的基本單位，例如：\n'
            '「起司漢堡」、「可樂」',
        onPressed: _handleCreate,
      ),
    );
  }

  void _handleSelected(Catalog catalog) {
    setState(() {
      selected = catalog;
    });
    _goTo(1);
  }

  Widget _searchItemBuilder(BuildContext context, Product item) {
    return ListTile(
      key: Key('search.${item.id}'),
      title: Text(item.name),
      onTap: () {
        item.searched();
        context.pushNamed(Routes.menuProduct, pathParameters: {
          'id': item.id,
        });
      },
    );
  }

  Widget _searchEmptyBuilder(BuildContext context, String text) {
    return ListTile(
      title: Text(S.menuSearchProductNotFound),
      leading: const Icon(KIcons.warn),
    );
  }

  void _handleCreate() async {
    // only catalog modal will return ID
    final catalog = await context.pushNamed(
      Routes.menuNew,
      queryParameters: {'id': selected?.id},
    );

    if (catalog is Catalog) {
      _handleSelected(catalog);
    }
  }

  Future<bool> _willPop() async {
    // if has no clients, it means menu is empty(build without PageView)
    if (!controller.hasClients || controller.page == 0) {
      return true;
    }

    _goTo(0).then((_) => setState(() => selected = null));
    return false;
  }

  Future<void> _goTo(int index) {
    return controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}
