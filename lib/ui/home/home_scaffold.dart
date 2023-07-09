import 'package:flutter/material.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/analysis_screen.dart';
import 'package:possystem/ui/cashier/cashier_screen.dart';
import 'package:possystem/ui/home/home_setup_screen.dart';
import '../stock/stock_screen.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({Key? key}) : super(key: key);

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.appTitle),
        centerTitle: true,
        shadowColor: Theme.of(context).colorScheme.shadow,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).gradientColors,
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        notificationPredicate: (ScrollNotification notification) {
          return notification.depth == 1;
        },
        // disable shadow after scrolled
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            key: const Key('home.order'),
            onPressed: () => Navigator.of(context).pushNamed(Routes.order),
            child: const Text('點餐'),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            _CustomTab(
                key: const Key('home.analysis'), text: S.homeTabAnalysis),
            _CustomTab(key: const Key('home.stock'), text: S.homeTabStock),
            _CustomTab(key: const Key('home.cashier'), text: S.homeTabCashier),
            _CustomTab(key: const Key('home.setting'), text: S.homeTabSetting),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AnalysisScreen(
            tab: TutorialInTab(controller: _tabController, index: 0),
          ),
          StockScreen(
            tab: TutorialInTab(controller: _tabController, index: 1),
          ),
          CashierScreen(
            tab: TutorialInTab(controller: _tabController, index: 2),
          ),
          HomeSetupScreen(
            tab: TutorialInTab(controller: _tabController, index: 3),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: Menu.instance.isEmpty ? 3 : 0,
      length: 4,
      vsync: this,
    );
  }
}

class _CustomTab extends StatelessWidget {
  final String text;

  const _CustomTab({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      iconMargin: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
        textScaleFactor: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
    );
  }
}
