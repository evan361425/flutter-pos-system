import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/footer.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/services/staff/employee_manager_service.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/home/home_chrome.dart';
import 'package:possystem/ui/home/home_tabs.dart';
import 'package:possystem/ui/staff/staff_lock_action.dart';
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
      floatingActionButton: const HomeOrderFab(),
      appBar: AppBar(
        title: Text(S.appTitle),
        centerTitle: true,
        flexibleSpace: const HomeFlexibleSpace(),
        excludeHeaderSemantics: true,
        actions: const [StaffLockAction()],
      ),
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: min(shell.currentIndex, homeBottomNavTabs.length - 1),
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
          for (final HomeTab e in homeBottomNavTabs)
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
    final tab =
        HomeTab.values.elementAtOrNull(widget.shell.currentIndex) ?? .analysis;
    final needNested = tab == .analysis;

    // Which means body have [CustomScrollView]
    if (needNested) {
      return Scaffold(
        key: scaffold,
        floatingActionButton: const HomeOrderFab(),
        drawer: _buildDrawer(tab),
        body: _Nested(title: S.title(tab.name), body: widget.shell),
      );
    }

    return Scaffold(
      key: scaffold,
      appBar: AppBar(
        title: Text(S.title(tab.name)),
        flexibleSpace: const HomeFlexibleSpace(),
        actions: const [StaffLockAction()],
      ),
      floatingActionButton: const HomeOrderFab(),
      drawer: _buildDrawer(tab),
      body: widget.shell,
    );
  }

  Widget _buildDrawer(HomeTab tab) {
    return Drawer(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: EmployeeManagerService.instance,
          builder: (context, _) {
            return ListView(
              padding: .zero,
              children: [
                const SizedBox(height: 48),
                for (final e in homeDrawerTabs)
                  if (e != .settings ||
                      EmployeeManagerService.instance.isManager)
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
                          onTap: () => _navTo(e.index),
                        ),
                        _closeDrawer,
                      ),
                    ),
                ListTile(
                  key: const Key('home.lock'),
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Lock terminal'),
                  onTap: () {
                    _closeDrawer();
                    EmployeeManagerService.instance.logout();
                    context.goNamed(AppRouteNames.lock);
                  },
                ),
                const Footer(),
              ],
            );
          },
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

  void _navTo(int index) {
    _closeDrawer();
    SpotlightShow.of(context).reset();
    widget.shell.goBranch(
      index,
      initialLocation: index == widget.shell.currentIndex,
    );
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
    final tab =
        HomeTab.values.elementAtOrNull(widget.shell.currentIndex) ?? .analysis;
    final needNested = tab == .analysis;

    // Which means body have [CustomScrollView]
    if (needNested) {
      return Scaffold(
        floatingActionButton: const HomeOrderFab(),
        body: _Nested(title: S.title(tab.name), body: _buildBody()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.title(tab.name)),
        flexibleSpace: const HomeFlexibleSpace(),
        actions: const [StaffLockAction()],
      ),
      floatingActionButton: const HomeOrderFab(),
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
        widget.shell.goBranch(
          index,
          initialLocation: index == widget.shell.currentIndex,
        );
        setState(() => railSelected.value = index);
      },
      leading: IconButton(
        icon: Icon(railExpanded.value ? Icons.close : Icons.menu),
        onPressed: () => railExpanded.value = !railExpanded.value,
      ),
      selectedIndex: min(
        railSelected.value,
        railExpanded.value ? 999 : homeImportantTabCount - 1,
      ),
      destinations: [
        for (final e in homeDrawerTabs)
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

  @override
  void dispose() {
    railExpanded.dispose();
    railSelected.dispose();
    super.dispose();
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
          flexibleSpace: const HomeFlexibleSpace(),
          actions: const [StaffLockAction()],
        ),
      ],
      body: body,
    );
  }
}
