import 'package:flutter/material.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/analysis/analysis_screen.dart';
import 'package:possystem/ui/cashier/cashier_screen.dart';
import 'package:possystem/ui/home/home_setup_screen.dart';
import '../stock/stock_screen.dart';
import 'package:simple_tip/simple_tip.dart';

class HomeScaffold extends StatefulWidget {
  final RouteObserver<ModalRoute<void>>? routeObserver;

  const HomeScaffold({Key? key, this.routeObserver}) : super(key: key);

  @override
  _HomeScaffoldState createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final analysisTipGrouper = GlobalKey<TipGrouperState>();
  final stockTipGrouper = GlobalKey<TipGrouperState>();
  final orderTipGrouper = GlobalKey<TipGrouperState>();
  final settingTipGrouper = GlobalKey<TipGrouperState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        AppbarTextButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.order),
          child: const Text('點餐'),
        )
      ]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).gradientColors,
            tileMode: TileMode.clamp,
          ),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              iconMargin: EdgeInsets.only(bottom: 6),
              icon: Icon(Icons.equalizer_outlined),
              text: '統計',
            ),
            Tab(
              iconMargin: EdgeInsets.only(bottom: 6),
              icon: Icon(Icons.store_outlined),
              text: '庫存',
            ),
            Tab(
              iconMargin: EdgeInsets.only(bottom: 6),
              icon: Icon(Icons.attach_money_outlined),
              text: '收銀',
            ),
            Tab(
              iconMargin: EdgeInsets.only(bottom: 6),
              icon: Icon(Icons.settings_outlined),
              text: '設定',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AnalysisScreen(
            routeObserver: widget.routeObserver,
            tipGrouper: analysisTipGrouper,
          ),
          StockScreen(
            routeObserver: widget.routeObserver,
            tipGrouper: stockTipGrouper,
          ),
          CashierScreen(
            routeObserver: widget.routeObserver,
            tipGrouper: orderTipGrouper,
          ),
          const HomeSetupScreen(),
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
