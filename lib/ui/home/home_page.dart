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
    goOrderPage() => context.pushNamed(Routes.order);
    // 如果使用 stateful 並另外建立 tabController，
    // 則會在 push page 時造成 Home 頁面重建，
    // 進而導致底下的頁面也重建，可能造成 tutorial 重複出現。
    return DefaultTabController(
      length: 4,
      initialIndex: tab.index,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('home.order'),
          onPressed: goOrderPage,
          icon: const Icon(Icons.store_sharp),
          label: const Text('點餐'),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                pinned: true,
                floating: true,
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
                // disable shadow after scrolled
                scrolledUnderElevation: 0,
                bottom: TabBar(tabs: [
                  _Tab(key: const Key('home.analysis'), text: S.homeTabAnalysis),
                  _Tab(key: const Key('home.stock'), text: S.homeTabStock),
                  _Tab(key: const Key('home.cashier'), text: S.homeTabCashier),
                  _Tab(key: const Key('home.setting'), text: S.homeTabSetting),
                ]),
                actions: [
                  TextButton(
                    onPressed: goOrderPage,
                    child: const Text('點餐'),
                  ),
                  const Tooltip(
                    message: '未來這裡的按鈕將會移除，請使用右下角的點餐按鈕。',
                    triggerMode: TooltipTriggerMode.tap,
                    showDuration: Duration(seconds: 30),
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(Icons.info_outline),
                  )
                ],
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
