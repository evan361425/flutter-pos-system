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
      return breakpoint <= Breakpoint.medium ? buildWithTab(context) : buildWithDrawer(context);
    });
  }

  Widget buildWithDrawer(BuildContext context) {
    return _Drawer(
      tab: tab,
      appBarBuilder: appBar,
    );
  }

  Widget buildWithTab(BuildContext context) {
    // Using DefaultTabController so descendant widgets can access the controller.
    // This allow building constant tab views, otherwise after push page,
    // the home page will rebuild(cause by go_route) and cause the tutorial to show again.
    // see https://github.com/flutter/flutter/issues/132049
    return DefaultTabController(
      length: 4,
      initialIndex: min(tab.index, 3),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('home.order'),
          onPressed: () => context.pushNamed(Routes.order),
          icon: const Icon(Icons.store_sharp),
          label: Text(S.orderBtn),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              appBar(
                context,
                title: Text(S.appTitle),
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

  Widget appBar(
    BuildContext context, {
    PreferredSizeWidget? bottom,
    required Widget title,
    Widget? action,
  }) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      floating: true,
      title: title,
      centerTitle: true,
      shadowColor: theme.colorScheme.shadow,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.gradientColors,
            tileMode: TileMode.clamp,
          ),
        ),
      ),
      // disable shadow after scrolled
      scrolledUnderElevation: 0,
      bottom: bottom,
      actions: action != null ? [action] : null,
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

class _Drawer extends StatefulWidget {
  final HomeTab tab;
  final Widget Function(
    BuildContext context, {
    required Widget title,
    Widget? action,
  }) appBarBuilder;

  const _Drawer({required this.tab, required this.appBarBuilder});

  @override
  _DrawerState createState() => _DrawerState();
}

class _DrawerState extends State<_Drawer> {
  final scaffold = GlobalKey<ScaffoldState>();
  late HomeTab tab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: Theme.of(context).gradientColors,
                    tileMode: TileMode.clamp,
                  ),
                ),
                child: Center(child: Text(S.appTitle)),
              ),
              for (final e in HomeTab.values)
                ListTile(
                  title: Text(S.title(e.name)),
                  selected: tab == e,
                  onTap: () {
                    if (e.route.isNotEmpty) {
                      context.pushNamed(e.route);
                      return;
                    }

                    scaffold.currentState?.closeDrawer();
                    if (mounted) {
                      setState(() {
                        tab = e;
                      });
                    }
                  },
                ),
              const Footer(),
            ],
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            widget.appBarBuilder(
              context,
              title: Text(S.title(tab.name)),
              action: tab.action,
            ),
          ];
        },
        body: tab.view,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    tab = widget.tab;
  }
}

enum HomeTab {
  analysis(view: AnalysisView()),
  stock(view: StockView()),
  cashier(view: CashierView()),
  setting(view: FeaturesPage(withScaffold: false)),
  // only show in drawer
  menu(route: Routes.menu),
  transit(view: TransitPage(withScaffold: false)),
  orderAttribute(view: OrderAttributePage(withAppbar: false), action: OrderAttributeAction()),
  stockQuantity(view: QuantityPage(withAppbar: false)),
  settingElf(view: FeatureRequestPage(withScaffold: false));

  final String route;
  final Widget view;
  final Widget? action;

  const HomeTab({this.route = '', this.view = const SizedBox(), this.action});
}
