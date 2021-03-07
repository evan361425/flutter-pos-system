import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/ui/menu/menu_screen.dart';

class HomeContainer extends StatelessWidget {
  HomeContainer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: tabBar(),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return MenuScreen();
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
        icon: Icon(Icons.collections_outlined),
        activeIcon: Icon(Icons.collections_sharp),
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
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment_ind_outlined),
        activeIcon: Icon(Icons.assignment_ind_sharp),
        label: '客戶資訊',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.article_outlined),
        activeIcon: Icon(Icons.article_sharp),
        label: '設定',
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
