import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/footer.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class HomePage extends StatelessWidget {
  final StatefulNavigationShell shell;

  final ValueNotifier<HomeMode> mode;

  const HomePage({super.key, required this.shell, required this.mode});

  @override
  Widget build(BuildContext context) {
    return TutorialWrapper(
      child: ListenableBuilder(
        listenable: mode,
        builder: (context, _) {
          SpotlightShow.of(context).reset();
          switch (mode.value) {
            case HomeMode.bottomNavigationBar:
              return _WithTab(shell: shell);
            case HomeMode.drawer:
              return _WithDrawer(shell: shell);
            case HomeMode.rail:
              return _WithRail(shell: shell);
          }
        },
      ),
    );
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
          SpotlightShow.of(context).reset();
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
          for (final HomeTab e in _bottomNavTabs)
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

class _WithDrawer extends StatelessWidget {
  final StatefulNavigationShell shell;
  final scaffold = GlobalKey<ScaffoldState>();

  _WithDrawer({required this.shell});

  @override
  Widget build(BuildContext context) {
    final tab = HomeTab.values[shell.currentIndex];
    final needNested = tab.index == HomeTab.analysis.index;

    // Which means body have [CustomScrollView]
    if (needNested) {
      return Scaffold(
        key: scaffold,
        floatingActionButton: _FAB(),
        drawer: _buildDrawer(context, tab),
        body: _Nested(title: S.title(tab.name), body: shell),
      );
    }

    return Scaffold(
      key: scaffold,
      appBar: AppBar(
        title: Text(S.title(tab.name)),
        flexibleSpace: const _FlexibleSpace(),
      ),
      floatingActionButton: _FAB(),
      drawer: _buildDrawer(context, tab),
      body: shell,
    );
  }

  Widget _buildDrawer(BuildContext context, HomeTab tab) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 48),
            for (final e in _drawerTabs)
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
                  onTap: () => _navTo(context, e),
                ),
              ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  void _navTo(BuildContext context, HomeTab tab) {
    scaffold.currentState?.closeDrawer();
    SpotlightShow.of(context).reset();
    shell.goBranch(tab.index, initialLocation: tab.index == shell.currentIndex);
  }
}

class _WithRail extends StatelessWidget {
  final StatefulNavigationShell shell;
  final ValueNotifier<bool> railExpanded = ValueNotifier(false);

  _WithRail({required this.shell});

  @override
  Widget build(BuildContext context) {
    final tab = HomeTab.values[shell.currentIndex];
    final needNested = tab.index == HomeTab.analysis.index;

    // Which means body have [CustomScrollView]
    if (needNested) {
      return Scaffold(
        floatingActionButton: _FAB(),
        body: _Nested(title: S.title(tab.name), body: _buildBody()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.title(tab.name)),
        flexibleSpace: const _FlexibleSpace(),
      ),
      floatingActionButton: _FAB(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Row(children: [
      ListenableBuilder(
        listenable: railExpanded,
        builder: (context, child) => NavigationRail(
          extended: railExpanded.value,
          onDestinationSelected: (int index) {
            SpotlightShow.of(context).reset();
            shell.goBranch(index, initialLocation: index == shell.currentIndex);
          },
          labelType: NavigationRailLabelType.all,
          destinations: [
            for (final e in _drawerTabs)
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
      Expanded(child: shell),
    ]);
  }
}

class _Nested extends StatelessWidget {
  final String title;

  final Widget body;

  const _Nested({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
        SliverAppBar(
          pinned: true,
          title: Text(title),
          flexibleSpace: const _FlexibleSpace(),
        ),
      ],
      body: body,
    );
  }
}

class _FAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tutorial(
      id: 'home.order',
      index: 99,
      spotlightBuilder: const SpotlightRectBuilder(borderRadius: 16.0),
      title: S.orderTutorialTitle,
      message: S.orderTutorialContent,
      child: FloatingActionButton.extended(
        key: const Key('home.order'),
        onPressed: () => context.pushNamed(Routes.order),
        icon: const Icon(Icons.store_sharp),
        label: Text(S.orderBtn),
      ),
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

const _bottomNavTabs = [
  HomeTab.analysis,
  HomeTab.stock,
  HomeTab.cashier,
  HomeTab.others,
];

const _drawerTabs = [
  HomeTab.analysis,
  HomeTab.stock,
  HomeTab.cashier,
  HomeTab.orderAttribute,
  HomeTab.menu,
  HomeTab.stockQuantity,
  HomeTab.transit,
  HomeTab.elf,
  HomeTab.setting,
];

enum HomeTab {
  analysis(
    icon: Icon(Icons.analytics_outlined),
    selectedIcon: Icon(Icons.analytics),
    important: true,
  ),
  stock(
    icon: Icon(Icons.inventory_2_outlined),
    selectedIcon: Icon(Icons.inventory_2),
    important: true,
  ),
  cashier(
    icon: Icon(Icons.monetization_on_outlined),
    selectedIcon: Icon(Icons.monetization_on),
    important: true,
  ),
  orderAttribute(
    icon: Icon(Icons.assignment_ind_outlined),
    selectedIcon: Icon(Icons.assignment_ind),
  ),
  menu(
    icon: Icon(Icons.collections_outlined),
    selectedIcon: Icon(Icons.collections),
  ),
  stockQuantity(
    icon: Icon(Icons.exposure),
    selectedIcon: Icon(Icons.exposure_outlined),
  ),
  transit(
    icon: Icon(Icons.local_shipping_outlined),
    selectedIcon: Icon(Icons.local_shipping),
  ),
  elf(
    icon: Icon(Icons.lightbulb_outlined),
    selectedIcon: Icon(Icons.lightbulb),
  ),
  setting(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
  ),

  /// The last items is entrypoint for mobile screen
  others(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
  );

  final Icon icon;
  final Icon selectedIcon;
  final bool important;

  const HomeTab({
    required this.icon,
    required this.selectedIcon,
    this.important = false,
  });
}
