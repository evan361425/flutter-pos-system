import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/analysis_view.dart';
import 'package:possystem/ui/cashier/cashier_view.dart';
import 'package:possystem/ui/home/setting_view.dart';
import '../stock/stock_view.dart';

class HomePage extends StatefulWidget {
  final HomeTab tab;

  const HomePage({
    Key? key,
    required this.tab,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
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
        // disable scrolling effect
        notificationPredicate: (ScrollNotification notification) {
          return notification.depth == 1;
        },
        // disable shadow after scrolled
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            key: const Key('home.order'),
            onPressed: () => context.pushNamed(Routes.order),
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
          AnalysisView(
            tab: TutorialInTab(controller: _tabController, index: 0),
          ),
          StockScreen(
            tab: TutorialInTab(controller: _tabController, index: 1),
          ),
          CashierView(
            tab: TutorialInTab(controller: _tabController, index: 2),
          ),
          SettingView(
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
      initialIndex: HomeTab.values.indexOf(widget.tab),
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
    // fix the font size, avoid scaling
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

enum HomeTab {
  analysis,
  stock,
  cashier,
  setting,
}
