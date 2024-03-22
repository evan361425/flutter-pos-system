import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/analysis_view.dart';
import 'package:possystem/ui/cashier/cashier_view.dart';
import 'package:possystem/ui/home/setting_view.dart';
import 'package:possystem/ui/stock/stock_view.dart';

class HomePage extends StatelessWidget {
  final HomeTab tab;

  const HomePage({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    // 如果使用 stateful 並另外建立 tabController，
    // 則會在 push page 時造成 Home 頁面重建，
    // 進而導致底下的頁面也重建，可能造成 tutorial 重複出現。
    return DefaultTabController(
      length: 4,
      initialIndex: tab.index,
      child: Scaffold(
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
          bottom: TabBar(tabs: [
            _Tab(key: const Key('home.analysis'), text: S.homeTabAnalysis),
            _Tab(key: const Key('home.stock'), text: S.homeTabStock),
            _Tab(key: const Key('home.cashier'), text: S.homeTabCashier),
            _Tab(key: const Key('home.setting'), text: S.homeTabSetting),
          ]),
        ),
        body: const TabBarView(
          children: [
            AnalysisView(tabIndex: 0),
            StockView(tabIndex: 1),
            CashierView(tabIndex: 2),
            SettingView(tabIndex: 3),
          ],
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

enum HomeTab {
  analysis,
  stock,
  cashier,
  setting,
}
