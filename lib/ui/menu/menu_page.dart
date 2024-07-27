import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/search_bar_wrapper.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/tutorial.dart';
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
  // TODO: set for wide screen
  final bool withScaffold;

  final Catalog? catalog;

  final bool productOnly;

  const MenuPage({
    super.key,
    this.catalog,
    this.productOnly = false,
    this.withScaffold = true,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Catalog? selected;
  late final PageController controller;

  @override
  Widget build(BuildContext context) {
    if (widget.withScaffold) {
      final fab = widget.productOnly
          ? null
          : FloatingActionButton(
              key: const Key('menu.add'),
              onPressed: selected == null ? _handleCatalogCreate : _handleProductCreate,
              tooltip: selected == null ? S.menuCatalogTitleCreate : S.menuProductTitleCreate,
              child: const Icon(KIcons.add),
            );

      return PopScope(
        canPop: selected == null,
        onPopInvoked: _onPopInvoked,
        child: TutorialWrapper(
          child: Scaffold(
            appBar: AppBar(
              title: Text(selected?.name ?? S.menuTitle),
              leading: PopButton(onPressed: _handlePop),
              actions: const [_SearchAction()],
            ),
            floatingActionButton: fab,
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
        ),
      );
    }

    return Row(children: [
      Expanded(child: firstView),
      const VerticalDivider(),
      Expanded(child: secondView),
    ]);
  }

  @override
  void didChangeDependencies() {
    context.watch<Menu>();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    selected = widget.catalog ?? (widget.withScaffold ? null : Menu.instance.itemList.firstOrNull);
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
          content: S.menuCatalogEmptyBody,
          onPressed: _handleCatalogCreate,
        ),
      );
    }

    if (widget.productOnly) {
      return const MenuProductList(catalog: null);
    }

    return MenuCatalogList(
      Menu.instance.itemList, // put it here to handle reload
      leading: widget.withScaffold
          ? null
          : const Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 0, 0),
              child: _SearchAction(withTextFiled: true),
            ),
      onSelected: _handleSelected,
      tailing: ElevatedButton.icon(
        onPressed: _handleCatalogCreate,
        label: Text(S.menuCatalogTitleCreate),
        icon: const Icon(KIcons.add),
      ),
    );
  }

  Widget get secondView {
    if (selected == null) {
      return Center(child: Text(S.menuProductNotSelected));
    }

    if (selected!.isEmpty) {
      // empty or not exist
      return Center(
        child: EmptyBody(
          key: const Key('catalog.empty'),
          content: S.menuProductEmptyBody,
          onPressed: _handleProductCreate,
        ),
      );
    }

    return MenuProductList(
      catalog: selected,
      tailing: widget.withScaffold
          ? null
          : ElevatedButton.icon(
              onPressed: _handleProductCreate,
              label: Text(S.menuProductTitleCreate),
              icon: const Icon(KIcons.add),
            ),
    );
  }

  void _handleSelected(Catalog catalog) {
    setState(() {
      selected = catalog;
    });
    _pageSlideTo(1);
  }

  Future<void> _handleCatalogCreate() async {
    // only catalog modal will return ID
    final catalog = await context.pushNamed(Routes.menuNew);

    if (catalog is Catalog) {
      _handleSelected(catalog);
    }
  }

  Future<void> _handleProductCreate() {
    return context.pushNamed(
      Routes.menuNew,
      queryParameters: {'id': selected?.id},
    );
  }

  void _handlePop() {
    if (_onPopInvoked(selected == null)) {
      if (context.mounted && context.canPop()) {
        context.pop();
      }
    }
  }

  bool _onPopInvoked(bool didPop) {
    if (!didPop) {
      _pageSlideTo(0).then((_) => setState(() => selected = null));
      return false;
    }

    return true;
  }

  Future<void> _pageSlideTo(int index) async {
    if (widget.withScaffold) {
      return controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }
}

class _SearchAction extends StatelessWidget {
  final bool withTextFiled;

  const _SearchAction({this.withTextFiled = false});

  @override
  Widget build(BuildContext context) {
    return SearchBarWrapper(
      key: const Key('menu.search'),
      hintText: S.menuSearchHint,
      text: withTextFiled ? '' : null,
      initData: Menu.instance.searchProducts(),
      search: (text) async => Menu.instance.searchProducts(text: text),
      itemBuilder: _searchItemBuilder,
      emptyBuilder: _searchEmptyBuilder,
    );
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
}
