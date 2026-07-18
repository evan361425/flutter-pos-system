import 'package:flutter/material.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/constant.dart';

const homeBottomNavTabs = [
  HomeTab.analysis,
  HomeTab.floorPlan,
  HomeTab.stock,
  HomeTab.cashier,
  HomeTab.more,
];

const homeDrawerTabs = [
  HomeTab.analysis,
  HomeTab.stock,
  HomeTab.cashier,
  HomeTab.floorPlan,
  HomeTab.orderAttributes,
  HomeTab.menu,
  HomeTab.printers,
  HomeTab.stockQuantities,
  HomeTab.transit,
  HomeTab.elf,
  HomeTab.settings,
  if (!isProd) HomeTab.debug,
];

/// Tabs marked [important] stay visible on a collapsed [NavigationRail].
final homeImportantTabCount = homeDrawerTabs.where((e) => e.important).length;

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
  floorPlan(
    icon: Icon(Icons.table_restaurant_outlined),
    selectedIcon: Icon(Icons.table_restaurant),
    important: true,
  ),
  orderAttributes(
    icon: Icon(Icons.assignment_ind_outlined),
    selectedIcon: Icon(Icons.assignment_ind),
  ),
  menu(
    icon: Icon(Icons.collections_outlined),
    selectedIcon: Icon(Icons.collections),
  ),
  printers(icon: Icon(Icons.print_outlined), selectedIcon: Icon(Icons.print)),
  stockQuantities(
    icon: Icon(Icons.exposure_outlined),
    selectedIcon: Icon(Icons.exposure),
  ),
  transit(
    icon: Icon(Icons.local_shipping_outlined),
    selectedIcon: Icon(Icons.local_shipping),
  ),
  elf(
    icon: Icon(Icons.lightbulb_outlined),
    selectedIcon: Icon(Icons.lightbulb),
  ),
  settings(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
  ),
  debug(
    icon: Icon(Icons.bug_report_outlined),
    selectedIcon: Icon(Icons.bug_report),
  ),

  /// Entrypoint for the mobile "more" screen.
  more(icon: Icon(Icons.dehaze_outlined), selectedIcon: Icon(Icons.dehaze));

  final Icon icon;
  final Icon selectedIcon;
  final bool important;

  const HomeTab({
    required this.icon,
    required this.selectedIcon,
    this.important = false,
  });

  Widget wrap(Widget child, [void Function()? action]) {
    return switch (this) {
      .menu => MenuTutorial(child: child),
      .orderAttributes => OrderAttrTutorial(onDismissed: action, child: child),
      _ => child,
    };
  }
}
