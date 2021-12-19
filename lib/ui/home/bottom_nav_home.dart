import 'package:flutter/material.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/analysis/analysis_screen.dart';
import 'package:possystem/ui/cashier/cashier_screen.dart';
import 'package:possystem/ui/home/other_screen.dart';
import '../stock/stock_screen.dart';
import 'package:simple_tip/simple_tip.dart';

class HomeScreen extends StatefulWidget {
  final RouteObserver<ModalRoute<void>>? routeObserver;

  const HomeScreen({Key? key, this.routeObserver}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo,
              Colors.blue,
              Colors.green,
            ],
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
              icon: Icon(Icons.lightbulb_outlined),
              text: '建議',
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
          const Center(child: Text('hi')),
          const OtherScreen(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }
}
