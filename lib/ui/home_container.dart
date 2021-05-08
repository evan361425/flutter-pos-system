import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/ui/home/home_screen.dart';
import 'package:possystem/ui/stock/stock_screen.dart';

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
          case _MainPageTypes.menu:
            return HomeScreen();
          case _MainPageTypes.stock:
            return StockScreen();
          default:
            return buildPage(context, index);
            break;
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

  Widget buildPage(BuildContext context, int index) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Page 1 of tab $index'),
      ),
      child: Center(
        child: CupertinoButton(
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (BuildContext context) {
                  return CupertinoPageScaffold(
                    navigationBar: CupertinoNavigationBar(
                      middle: Text('Page 2 of tab $index'),
                    ),
                    child: Center(
                      child: CupertinoButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Back'),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          child: const Text('Next page'),
        ),
      ),
    );
  }
}

enum _MainPageTypes {
  menu,
  analysis,
  stock,
  customer,
  settings,
}
