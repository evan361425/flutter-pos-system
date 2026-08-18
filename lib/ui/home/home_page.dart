import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/footer.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/order_page.dart';
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
          return switch (mode.value) {
            .bottomNavigationBar => _WithTab(shell: shell),
            .drawer => _WithDrawer(shell: shell),
            .rail => _WithRail(shell: shell),
          };
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
      appBar: AppBar(
        title: Text(S.appTitle),
        centerTitle: true,
        flexibleSpace: const _FlexibleSpace(),
        excludeHeaderSemantics: true,
      ),
      body: shell.currentIndex == 0 ? const OrderPage(embedded: true) : shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex == 0
            ? 0
            : _bottomNavTabs
                  .indexWhere((e) => e.branchIndex == shell.currentIndex)
                  .clamp(0, 3),
        onDestinationSelected: (index) {
          SpotlightShow.of(context).reset();
          final tab = _bottomNavTabs[index];
          if (tab == .order) {
            shell.goBranch(0, initialLocation: shell.currentIndex == 0);
          } else {
            shell.goBranch(
              tab.branchIndex!,
              initialLocation: tab.branchIndex == shell.currentIndex,
            );
          }
        },
        destinations: [
          for (final _Tab e in _bottomNavTabs)
            NavigationDestination(
              key: Key('home.${e.name}'),
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

  const _WithDrawer({required this.shell});

  @override
  State<_WithDrawer> createState() => _WithDrawerState();
}

class _WithDrawerState extends State<_WithDrawer> {
  final scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final tab = _Tab.fromBranch(widget.shell.currentIndex);
    final needNested = tab == .analysis;

    // Which means body have [CustomScrollView]
    if (needNested) {
      return Scaffold(
        key: scaffold,
        drawer: _buildDrawer(tab),
        body: _Nested(title: S.title(tab.name), body: widget.shell),
      );
    }

    return Scaffold(
      key: scaffold,
      appBar: AppBar(
        title: Text(S.title(tab.name)),
        flexibleSpace: const _FlexibleSpace(),
      ),
      drawer: _buildDrawer(tab),
      body: widget.shell,
    );
  }

  Widget _buildDrawer(_Tab tab) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: .zero,
          children: [
            const SizedBox(height: 48),
            for (final e in _drawerTabs)
              Padding(
                padding: const .fromLTRB(16, 0, 12, 0),
                child: e.wrap(
                  ListTile(
                    key: Key('home.${e.name}'),
                    leading: tab == e ? e.selectedIcon : e.icon,
                    title: Text(S.title(e.name)),
                    selected: tab == e,
                    visualDensity: .compact,
                    shape: const RoundedRectangleBorder(
                      borderRadius: .all(.circular(8)),
                    ),
                    onTap: () => _navTo(e),
                  ),
                  _closeDrawer,
                ),
              ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    if (Cache.instance.get<bool>('tutorial.home.order') != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scaffold.currentState?.openDrawer();
      });
    }
    super.initState();
  }

  void _navTo(_Tab tab) {
    _closeDrawer();
    SpotlightShow.of(context).reset();
    if (tab == .order) {
      context.pushNamed(Routes.order);
    } else {
      widget.shell.goBranch(
        tab.branchIndex!,
        initialLocation: tab.branchIndex == widget.shell.currentIndex,
      );
    }
  }

  void _closeDrawer() {
    scaffold.currentState?.closeDrawer();
  }
}

class _WithRail extends StatefulWidget {
  final StatefulNavigationShell shell;

  const _WithRail({required this.shell});

  @override
  State<_WithRail> createState() => _WithRailState();
}

class _WithRailState extends State<_WithRail> {
  late final ValueNotifier<bool> railExpanded;
  late final ValueNotifier<int> railSelected;

  @override
  Widget build(BuildContext context) {
    final tab = _Tab.fromBranch(widget.shell.currentIndex);
    final needNested = tab == .analysis;

    // Which means body have [CustomScrollView]
    if (needNested) {
      return Scaffold(
        body: _Nested(title: S.title(tab.name), body: _buildBody()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.title(tab.name)),
        flexibleSpace: const _FlexibleSpace(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Row(
      children: [
        ListenableBuilder(
          listenable: railExpanded,
          builder: (context, child) => ListenableBuilder(
            listenable: railSelected,
            builder: (context, child) => _buildRail(),
          ),
        ),
        const VerticalDivider(),
        Expanded(child: widget.shell),
      ],
    );
  }

  Widget _buildRail() {
    return NavigationRail(
      extended: railExpanded.value,
      onDestinationSelected: (int index) {
        SpotlightShow.of(context).reset();
        final tabs = railExpanded.value
            ? _drawerTabs
            : _drawerTabs.where((e) => e.important).toList();
        final tab = tabs[index];
        if (tab == .order) {
          context.pushNamed(Routes.order);
        } else {
          widget.shell.goBranch(
            tab.branchIndex!,
            initialLocation: tab.branchIndex == widget.shell.currentIndex,
          );
          setState(() => railSelected.value = index);
        }
      },
      leading: IconButton(
        icon: Icon(railExpanded.value ? Icons.close : Icons.menu),
        onPressed: () => railExpanded.value = !railExpanded.value,
      ),
      selectedIndex: min(railSelected.value, railExpanded.value ? 999 : 2),
      destinations: [
        for (final e in _drawerTabs)
          // Show all tabs if expanded, otherwise only show important tabs
          if (railExpanded.value || e.important)
            NavigationRailDestination(
              icon: e.icon,
              selectedIcon: e.selectedIcon,
              label: e.wrap(Text(S.title(e.name))),
            ),
      ],
    );
  }

  @override
  void initState() {
    railExpanded = ValueNotifier(
      Cache.instance.get<bool>('tutorial.home.order') != true,
    );
    railSelected = ValueNotifier(widget.shell.currentIndex);
    super.initState();
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
          tileMode: .clamp,
        ),
      ),
    );
  }
}

const _bottomNavTabs = [_Tab.order, _Tab.stock, _Tab.cashier, _Tab.more];

const _drawerTabs = [
  _Tab.order,
  _Tab.stock,
  _Tab.cashier,
  _Tab.analysis,
  _Tab.orderAttributes,
  _Tab.menu,
  _Tab.printers,
  _Tab.stockQuantities,
  _Tab.transit,
  _Tab.elf,
  _Tab.settings,
  if (!isProd) _Tab.debug,
];

enum _Tab {
  order(
    icon: Icon(Icons.shopping_cart_outlined),
    selectedIcon: Icon(Icons.shopping_cart),
    important: true,
  ),
  analysis(
    icon: Icon(Icons.analytics_outlined),
    selectedIcon: Icon(Icons.analytics),
    important: true,
    branchIndex: 0,
  ),
  stock(
    icon: Icon(Icons.inventory_2_outlined),
    selectedIcon: Icon(Icons.inventory_2),
    important: true,
    branchIndex: 1,
  ),
  cashier(
    icon: Icon(Icons.monetization_on_outlined),
    selectedIcon: Icon(Icons.monetization_on),
    important: true,
    branchIndex: 2,
  ),
  orderAttributes(
    icon: Icon(Icons.assignment_ind_outlined),
    selectedIcon: Icon(Icons.assignment_ind),
    branchIndex: 3,
  ),
  menu(
    icon: Icon(Icons.collections_outlined),
    selectedIcon: Icon(Icons.collections),
    branchIndex: 4,
  ),
  printers(
    icon: Icon(Icons.print_outlined),
    selectedIcon: Icon(Icons.print),
    branchIndex: 5,
  ),
  stockQuantities(
    icon: Icon(Icons.exposure_outlined),
    selectedIcon: Icon(Icons.exposure),
    branchIndex: 6,
  ),
  transit(
    icon: Icon(Icons.local_shipping_outlined),
    selectedIcon: Icon(Icons.local_shipping),
    branchIndex: 7,
  ),
  elf(
    icon: Icon(Icons.lightbulb_outlined),
    selectedIcon: Icon(Icons.lightbulb),
    branchIndex: 8,
  ),
  settings(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
    branchIndex: 9,
  ),
  debug(
    icon: Icon(Icons.bug_report_outlined),
    selectedIcon: Icon(Icons.bug_report),
    branchIndex: 10,
  ),

  /// entrypoint for mobile screen
  more(
    icon: Icon(Icons.dehaze_outlined),
    selectedIcon: Icon(Icons.dehaze),
    branchIndex: 3,
  );

  final Icon icon;
  final Icon selectedIcon;
  final bool important;
  final int? branchIndex;

  const _Tab({
    required this.icon,
    required this.selectedIcon,
    this.important = false,
    this.branchIndex,
  });

  static _Tab fromBranch(int index) {
    return _drawerTabs.firstWhere(
      (e) => e.branchIndex == index,
      orElse: () => .analysis,
    );
  }

  Widget wrap(Widget child, [void Function()? action]) {
    return switch (this) {
      .menu => MenuTutorial(child: child),
      // after finish this tutorial, we will close the drawer
      .orderAttributes => OrderAttrTutorial(onDismissed: action, child: child),
      _ => child,
    };
  }
}
