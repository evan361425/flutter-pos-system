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
    super.key,
    this.catalog,
    this.productOnly = false,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Catalog? selected;
  late final PageController controller;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selected == null,
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: Text(selected?.name ?? S.menuTitle),
          leading: PopButton(
            onPressed: () {
              if (_onPopInvoked(selected == null)) {
                if (context.mounted && context.canPop()) {
                  context.pop();
                }
              }
            },
          ),
          actions: [
            if (!widget.productOnly)
              IconButton(
                tooltip: selected == null ? S.menuCatalogTitleReorder : S.menuProductTitleReorder,
                onPressed: () {
                  selected == null
                      ? context.pushNamed(Routes.menuReorder)
                      : context.pushNamed(
                          Routes.menuCatalogReorder,
                          pathParameters: {'id': selected!.id},
                        );
                },
                icon: const Icon(KIcons.reorder),
              ),
            SearchBarWrapper(
              key: const Key('menu.search'),
              hintText: S.menuSearchHint,
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
                tooltip: selected == null ? S.menuCatalogTitleCreate : S.menuProductTitleCreate,
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
          helperText: S.menuCatalogEmptyBody,
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
        helperText: S.menuProductEmptyBody,
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
      title: Text(S.menuSearchNotFound),
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

  bool _onPopInvoked(bool didPop) {
    if (!didPop) {
      _goTo(0).then((_) => setState(() => selected = null));
      return false;
    }

    return true;
  }

  Future<void> _goTo(int index) {
    return controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}
