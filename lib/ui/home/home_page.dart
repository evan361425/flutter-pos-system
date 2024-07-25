import 'dart:collection';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/router_pop_scope.dart';
import 'package:possystem/components/style/footer.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/analysis_view.dart';
import 'package:possystem/ui/cashier/cashier_view.dart';
import 'package:possystem/ui/home/feature_request_page.dart';
import 'package:possystem/ui/home/features_page.dart';
import 'package:possystem/ui/home/setting_view.dart';
import 'package:possystem/ui/menu/menu_page.dart';
import 'package:possystem/ui/order_attr/order_attribute_page.dart';
import 'package:possystem/ui/stock/quantity_page.dart';
import 'package:possystem/ui/stock/stock_view.dart';
import 'package:possystem/ui/transit/transit_page.dart';

class HomePage extends StatelessWidget {
  final HomeTab tab;

  const HomePage({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final breakpoint = Breakpoint.find(box: constraints);

      return breakpoint <= Breakpoint.medium
          // Using DefaultTabController so descendant widgets can access the controller.
          // This allow building constant tab views, otherwise after push page,
          // the home page will rebuild(cause by go_route) and cause the tutorial to show again.
          // see https://github.com/flutter/flutter/issues/132049
          ? DefaultTabController(
              length: 4,
              initialIndex: min(tab.index, 3),
              child: _WithTab(tab: tab),
            )
          : _WithDrawer(tab: tab);
    });
  }
}

class _WithTab extends StatefulWidget {
  final HomeTab tab;

  const _WithTab({required this.tab});

  @override
  State<_WithTab> createState() => _WithTabState();
}

class _WithTabState extends State<_WithTab> {
  final navHistory = Queue<int>();
  final canPop = ValueNotifier<bool>(true);
  late TabController controller;
  // prevent adding the history index while popping
  bool isPopping = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: canPop,
      builder: (context, child) => RouterPopScope(
        canPop: navHistory.isEmpty,
        onPopInvoked: _pop,
        child: child!,
      ),
      child: Scaffold(
        floatingActionButton: _FAB(),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                pinned: true,
                floating: true,
                title: Text(S.appTitle),
                centerTitle: true,
                flexibleSpace: const _FlexibleSpace(),
                // disable shadow after scrolled
                scrolledUnderElevation: 0,
                bottom: TabBar(tabs: [
                  _Tab(key: const Key('home.analysis'), text: S.analysisTab),
                  _Tab(key: const Key('home.stock'), text: S.stockTab),
                  _Tab(key: const Key('home.cashier'), text: S.cashierTab),
                  _Tab(key: const Key('home.setting'), text: S.settingTab),
                ]),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              AnalysisView(tabIndex: 0),
              StockView(tabIndex: 1),
              CashierView(tabIndex: 2),
              SettingView(tabIndex: 3),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    controller = DefaultTabController.of(context);
    controller.addListener(_monitorNav);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.removeListener(_monitorNav);
    super.dispose();
  }

  _monitorNav() {
    // when animation is done and the index is changed
    if (!controller.indexIsChanging && controller.index != controller.previousIndex) {
      if (isPopping) {
        isPopping = false;
        return;
      }

      final index = controller.index;
      if (navHistory.length >= 3) {
        navHistory.removeFirst();
      }
      navHistory.add(index);
      canPop.value = false;
    }
  }

  void _pop(bool didPop) {
    if (navHistory.isNotEmpty) {
      navHistory.removeLast();

      if (mounted) {
        isPopping = true;
        controller.animateTo(navHistory.lastOrNull ?? 0);
        canPop.value = navHistory.isEmpty;
      }
    }
  }
}

class _WithDrawer extends StatefulWidget {
  final HomeTab tab;

  const _WithDrawer({required this.tab});

  @override
  _WithDrawerState createState() => _WithDrawerState();
}

class _WithDrawerState extends State<_WithDrawer> {
  final navHistory = Queue<HomeTab>();
  final scaffold = GlobalKey<ScaffoldState>();
  late HomeTab tab;

  @override
  Widget build(BuildContext context) {
    final needNested = tab == HomeTab.analysis;
    final List<Widget> actions = tab.action == null ? const [] : [tab.action!];

    return RouterPopScope(
      canPop: navHistory.isEmpty,
      onPopInvoked: _pop,
      child: Scaffold(
        key: scaffold,
        appBar: needNested
            ? null
            : AppBar(
                title: Text(S.title(tab.name)),
                flexibleSpace: const _FlexibleSpace(),
                actions: actions,
              ),
        floatingActionButton: _FAB(),
        drawer: Drawer(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 48),
                for (final e in HomeTab.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListTile(
                      title: Text(S.title(e.name)),
                      selected: tab == e,
                      visualDensity: VisualDensity.compact,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      onTap: () => _navTo(e),
                    ),
                  ),
                const Footer(),
              ],
            ),
          ),
        ),
        body: needNested
            ? NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
                  SliverAppBar(
                    pinned: true,
                    title: Text(S.title(tab.name)),
                    flexibleSpace: const _FlexibleSpace(),
                    actions: actions,
                  ),
                ],
                body: tab.view,
              )
            : tab.view,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    tab = widget.tab;
  }

  void _navTo(HomeTab tab) {
    scaffold.currentState?.closeDrawer();
    if (navHistory.length >= 3) {
      navHistory.removeFirst();
    }
    navHistory.add(tab);
    if (mounted) {
      setState(() => this.tab = tab);
    }
  }

  void _pop(bool didPop) {
    if (navHistory.isNotEmpty) {
      navHistory.removeLast();

      if (mounted) {
        setState(() => tab = navHistory.lastOrNull ?? HomeTab.analysis);
      }
    }
  }
}

class _FAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      key: const Key('home.order'),
      onPressed: () => context.pushNamed(Routes.order),
      icon: const Icon(Icons.store_sharp),
      label: Text(S.orderBtn),
    );
  }
}

class _FlexibleSpace extends StatelessWidget {
  const _FlexibleSpace();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).gradientColors,
          tileMode: TileMode.clamp,
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String text;

  const _Tab({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    // fix the font size, avoid scaling
    return MediaQuery.withNoTextScaling(
      child: Tab(
        iconMargin: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }
}

// The order is important for the drawer scaffold
enum HomeTab {
  analysis(view: AnalysisView()),
  stock(view: StockView()),
  cashier(view: CashierView()),
  orderAttribute(view: OrderAttributePage(withScaffold: false), action: OrderAttributeAction()),
  menu(view: MenuPage(withScaffold: false), action: MenuAction()),
  stockQuantity(view: QuantityPage(withScaffold: false), action: QuantityAction()),
  transit(view: TransitPage(withScaffold: false)),
  settingElf(view: FeatureRequestPage(withScaffold: false)),
  setting(view: FeaturesPage(withScaffold: false));

  final Widget view;
  final Widget? action;

  const HomeTab({this.view = const SizedBox(), this.action});
}
