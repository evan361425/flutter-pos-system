import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/search_bar_wrapper.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/breakpoint.dart';
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
  late bool singleView;

  @override
  Widget build(BuildContext context) {
    context.watch<Menu>();

    final width = MediaQuery.sizeOf(context).width;
    singleView = Breakpoint.find(width: width) <= Breakpoint.medium;
    // if we are in two-view mode, we should always show the second view
    if (!singleView) {
      selected ??= Menu.instance.itemList.firstOrNull;
    }

    // if selected catalog is not exist, reset it
    if (selected != null && !Menu.instance.hasItem(selected!.id)) {
      selected = null;
    }

    if (singleView) {
      return PopScope(
        key: const Key('menu_page'),
        canPop: selected == null,
        onPopInvokedWithResult: _onPopInvoked,
        child: Scaffold(
          appBar: AppBar(
            title: Text(selected?.name ?? S.menuTitle),
            leading: PopButton(onPressed: _handlePop),
            actions: const [_SearchAction()],
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

    // no need to use Scaffold here, because this will be wrapped by HomePage
    return Row(key: const Key('menu_page'), crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: firstView),
      const VerticalDivider(),
      Expanded(child: secondView),
    ]);
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
          content: S.menuCatalogEmptyBody,
          onPressed: _handleCatalogCreate,
        ),
      );
    }

    if (widget.productOnly && singleView) {
      return const MenuProductList(catalog: null);
    }

    final addButton = Row(children: [
      Expanded(
        child: ElevatedButton.icon(
          key: const Key('menu.add_catalog'),
          onPressed: _handleCatalogCreate,
          label: Text(S.menuCatalogTitleCreate),
          icon: const Icon(KIcons.add),
        ),
      ),
    ]);

    return MenuCatalogList(
      Menu.instance.itemList, // put it here to handle reload
      leading: Column(children: [
        if (!singleView)
          const Padding(
            padding: EdgeInsets.only(bottom: kInternalSpacing),
            child: _SearchAction(withTextFiled: true),
          ),
        addButton,
      ]),
      onSelected: _handleSelected,
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
      leading: Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            key: const Key('menu.add_product'),
            onPressed: _handleProductCreate,
            label: Text(S.menuProductTitleCreate),
            icon: const Icon(KIcons.add),
          ),
        ),
      ]),
    );
  }

  void _handleSelected(Catalog catalog) {
    if (mounted) {
      setState(() {
        selected = catalog;
      });
      _pageSlideTo(1);
    }
  }

  Future<void> _handleCatalogCreate() async {
    // only catalog modal will return ID
    final catalog = await context.pushNamed(Routes.menuCatalogCreate);

    if (catalog is Catalog) {
      _handleSelected(catalog);
    }
  }

  Future<void> _handleProductCreate() async {
    final id = await context.pushNamed(
      Routes.menuCatalogCreate,
      queryParameters: {'id': selected?.id},
    );
    if (id is String && mounted) {
      context.pushNamed(Routes.menuProduct, pathParameters: {'id': id});
    }
  }

  void _handlePop() {
    if (_onPopInvoked(selected == null, null)) {
      PopButton.safePop(context, path: '${Routes.base}/_');
    }
  }

  bool _onPopInvoked(bool didPop, dynamic result) {
    if (!didPop) {
      _pageSlideTo(0).then((_) => setState(() => selected = null));
      return false;
    }

    return true;
  }

  Future<void> _pageSlideTo(int index) async {
    if (singleView) {
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
