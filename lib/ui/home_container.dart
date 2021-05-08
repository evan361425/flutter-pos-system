import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/ui/home/home_screen.dart';
import 'package:possystem/ui/stock/stock_screen.dart';

import 'analysis/analysis_screen.dart';

class HomeContainer extends StatelessWidget {
  const HomeContainer({Key key}) : super(key: key);

  static final tabController = CupertinoTabController();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: tabController,
      tabBar: tabBar(),
      tabBuilder: (context, index) {
        switch (_MainPageTypes.values[index]) {
          case _MainPageTypes.stock:
            return StockScreen();
          case _MainPageTypes.analysis:
            return AnalysisScreen();
          case _MainPageTypes.home:
          default:
            return HomeScreen();
        }
      },
    );
  }

  CupertinoTabBar tabBar() {
    return CupertinoTabBar(items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_sharp),
        label: '主頁',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.equalizer_outlined),
        activeIcon: Icon(Icons.equalizer_sharp),
        label: '統計',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.store_outlined),
        activeIcon: Icon(Icons.store_sharp),
        label: '庫存',
      ),
    ]);
  }
}

enum _MainPageTypes {
  home,
  analysis,
  stock,
}
