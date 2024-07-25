import 'dart:collection';
import 'dart:math' show min;

import 'package:collection/collection.dart';
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
          : _WithDrawer(tab: tab, breakpoint: breakpoint);
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

  final Breakpoint breakpoint;

  const _WithDrawer({required this.tab, required this.breakpoint});

  @override
  _WithDrawerState createState() => _WithDrawerState();
}

class _WithDrawerState extends State<_WithDrawer> {
  final navHistory = Queue<HomeTab>();
  final scaffold = GlobalKey<ScaffoldState>();
  late bool useDrawer;
  ValueNotifier<bool> railExpanded = ValueNotifier(false);
  late HomeTab tab;

  @override
  Widget build(BuildContext context) {
    final needNested = tab == HomeTab.analysis;

    return RouterPopScope(
      canPop: navHistory.isEmpty,
      onPopInvoked: _pop,
      child: needNested ? _buildWithNestedScrollView() : _buildSimple(),
    );
  }

  @override
  void initState() {
    super.initState();
    tab = widget.tab;
    useDrawer = widget.breakpoint <= Breakpoint.large;
  }

  Widget _buildSimple() {
    return Scaffold(
      key: scaffold,
      appBar: AppBar(
        title: Text(S.title(tab.name)),
        flexibleSpace: const _FlexibleSpace(),
      ),
      floatingActionButton: _FAB(),
      drawer: useDrawer ? _buildDrawer() : null,
      body: _buildBody(),
    );
  }

  /// Which means body have [CustomScrollView]
  Widget _buildWithNestedScrollView() {
    return Scaffold(
      key: scaffold,
      floatingActionButton: _FAB(),
      drawer: useDrawer ? _buildDrawer() : null,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            title: Text(S.title(tab.name)),
            flexibleSpace: const _FlexibleSpace(),
          ),
        ],
        body: _buildBody(),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 48),
            for (final e in HomeTab.values)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
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
    );
  }

  Widget _buildBody() {
    if (useDrawer) {
      return tab.view;
    }

    return Row(children: [
      ListenableBuilder(
        listenable: railExpanded,
        builder: (context, child) => NavigationRail(
          extended: railExpanded.value,
          onDestinationSelected: (int index) => _navTo(HomeTab.values[index]),
          labelType: NavigationRailLabelType.all,
          destinations: [
            for (final e in HomeTab.values)
              if (railExpanded.value || e.important)
                NavigationRailDestination(
                  icon: Icon(e.icon),
                  selectedIcon: Icon(e.selectedIcon),
                  label: Text(S.title(e.name)),
                ),
          ],
          selectedIndex: 0,
        ),
      ),
      const VerticalDivider(),
      Expanded(child: tab.view),
    ]);
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
  analysis(
    view: AnalysisView(),
    icon: Icons.analytics_outlined,
    selectedIcon: Icons.analytics,
    important: true,
  ),
  stock(
    view: StockView(),
    icon: Icons.inventory_outlined,
    selectedIcon: Icons.inventory,
    important: true,
  ),
  cashier(
    view: CashierView(circularActions: false),
    icon: Icons.monetization_on_outlined,
    selectedIcon: Icons.monetization_on,
    important: true,
  ),
  orderAttribute(
    view: OrderAttributePage(withScaffold: false),
    icon: Icons.people_alt_outlined,
    selectedIcon: Icons.people_alt,
  ),
  menu(
    view: MenuPage(withScaffold: false),
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
  ),
  stockQuantity(
    view: QuantityPage(withScaffold: false),
    icon: Icons.difference,
    selectedIcon: Icons.difference_outlined,
  ),
  transit(
    view: TransitPage(withScaffold: false),
    icon: Icons.local_shipping_outlined,
    selectedIcon: Icons.local_shipping,
  ),
  settingElf(
    view: FeatureRequestPage(withScaffold: false),
    icon: Icons.star_border_outlined,
    selectedIcon: Icons.star,
  ),
  setting(
    view: FeaturesPage(withScaffold: false),
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
  ;

  final Widget view;
  final IconData icon;
  final IconData selectedIcon;
  final bool important;

  const HomeTab({
    required this.view,
    required this.icon,
    required this.selectedIcon,
    this.important = false,
  });
}
