import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final StatefulNavigationShell shell;

  const HomePage({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final breakpoint = Breakpoint.find(box: constraints);

      return breakpoint <= Breakpoint.medium
          ? _WithTab(shell: shell)
          : _WithDrawer(shell: shell, breakpoint: breakpoint);
    });
  }
}

class _WithTab extends StatelessWidget {
  final StatefulNavigationShell shell;

  const _WithTab({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _FAB(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: true,
              title: Text(S.appTitle),
              centerTitle: true,
              flexibleSpace: const _FlexibleSpace(),
              // disable shadow after scrolled
              // scrolledUnderElevation: 0,
            ),
          ];
        },
        body: shell,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: min(shell.currentIndex, 3),
        onDestinationSelected: (index) {
          index = index == 3 ? HomeTab.others.index : index;
          shell.goBranch(
            index,
            // A common pattern when using bottom navigation bars is to support
            // navigating to the initial location when tapping the item that is
            // already active. This example demonstrates how to support this behavior,
            // using the initialLocation parameter of goBranch.
            initialLocation: index == shell.currentIndex,
          );
        },
        destinations: [
          for (final HomeTab e in [HomeTab.analysis, HomeTab.stock, HomeTab.cashier, HomeTab.setting])
            NavigationDestination(
              icon: e.icon,
              label: S.title(e.name),
              selectedIcon: e.selectedIcon,
            ),
        ],
      ),
    );
  }
}

class _WithDrawer extends StatefulWidget {
  final StatefulNavigationShell shell;

  final Breakpoint breakpoint;

  const _WithDrawer({required this.shell, required this.breakpoint});

  @override
  _WithDrawerState createState() => _WithDrawerState();
}

class _WithDrawerState extends State<_WithDrawer> {
  final scaffold = GlobalKey<ScaffoldState>();
  late bool withoutRail;
  ValueNotifier<bool> railExpanded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final tab = HomeTab.values[widget.shell.currentIndex];
    final needNested = tab.index == HomeTab.analysis.index;

    return needNested ? _buildWithNestedScrollView(tab) : _buildSimple(tab);
  }

  @override
  void didChangeDependencies() {
    withoutRail = widget.breakpoint <= Breakpoint.large;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    withoutRail = widget.breakpoint <= Breakpoint.large;
  }

  Widget _buildSimple(HomeTab tab) {
    return Scaffold(
      key: scaffold,
      appBar: AppBar(
        title: Text(S.title(tab.name)),
        flexibleSpace: const _FlexibleSpace(),
      ),
      floatingActionButton: _FAB(),
      drawer: withoutRail ? _buildDrawer(tab) : null,
      body: _buildBody(),
    );
  }

  /// Which means body have [CustomScrollView]
  Widget _buildWithNestedScrollView(HomeTab tab) {
    return Scaffold(
      key: scaffold,
      floatingActionButton: _FAB(),
      drawer: withoutRail ? _buildDrawer(tab) : null,
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

  Widget _buildDrawer(HomeTab tab) {
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
                  leading: e.icon,
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
    if (withoutRail) {
      return widget.shell;
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
                  icon: e.icon,
                  selectedIcon: e.selectedIcon,
                  label: Text(S.title(e.name)),
                ),
          ],
          selectedIndex: 0,
        ),
      ),
      const VerticalDivider(),
      Expanded(child: widget.shell),
    ]);
  }

  void _navTo(HomeTab tab) {
    scaffold.currentState?.closeDrawer();
    if (mounted) {
      widget.shell.goBranch(tab.index, initialLocation: tab.index == widget.shell.currentIndex);
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
    icon: Icon(Icons.analytics_outlined),
    selectedIcon: Icon(Icons.analytics),
    important: true,
  ),
  stock(
    view: StockView(),
    icon: Icon(Icons.inventory_outlined),
    selectedIcon: Icon(Icons.inventory),
    important: true,
  ),
  cashier(
    view: CashierView(),
    icon: Icon(Icons.monetization_on_outlined),
    selectedIcon: Icon(Icons.monetization_on),
    important: true,
  ),
  orderAttribute(
    view: OrderAttributePage(withScaffold: false),
    icon: Icon(Icons.assignment_ind_outlined),
    selectedIcon: Icon(Icons.assignment_ind),
  ),
  menu(
    view: MenuPage(withScaffold: false),
    icon: Icon(Icons.collections_outlined),
    selectedIcon: Icon(Icons.collections),
  ),
  quantities(
    view: QuantityPage(withScaffold: false),
    icon: Icon(Icons.exposure),
    selectedIcon: Icon(Icons.exposure_outlined),
  ),
  transit(
    view: TransitPage(withScaffold: false),
    icon: Icon(Icons.local_shipping_outlined),
    selectedIcon: Icon(Icons.local_shipping),
  ),
  elf(
    view: FeatureRequestPage(withScaffold: false),
    icon: Icon(Icons.lightbulb_outlined),
    selectedIcon: Icon(Icons.lightbulb),
  ),
  setting(
    view: FeaturesPage(withScaffold: false),
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
  ),

  /// The last items is entrypoint for mobile screen
  others(
    view: SettingView(),
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
  );

  final Widget view;
  final Icon icon;
  final Icon selectedIcon;
  final bool important;

  const HomeTab({
    required this.view,
    required this.icon,
    required this.selectedIcon,
    this.important = false,
  });
}
