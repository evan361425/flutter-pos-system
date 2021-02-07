import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/routes.dart';

class BackendBottomNavBar extends StatelessWidget {
  final BackendBottomNavs _index;
  BackendBottomNavBar(this._index);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          activeIcon: Icon(Icons.article),
          label: Local.of(context).t('spreadsheet'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.equalizer_outlined),
          activeIcon: Icon(Icons.equalizer),
          label: Local.of(context).t('analysis'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.collections_outlined),
          activeIcon: Icon(Icons.collections),
          label: Local.of(context).t('menu'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store_outlined),
          activeIcon: Icon(Icons.store),
          label: Local.of(context).t('stock'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_ind_outlined),
          activeIcon: Icon(Icons.assignment_ind),
          label: Local.of(context).t('customer'),
        ),
      ],
      currentIndex: _index.index,
      fixedColor: Theme.of(context).primaryColor,
      onTap: (int index) {
        // get the enum key string
        final name = BackendBottomNavs.values[index].toString().split('.').last;
        // TODO: x-axis animation
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return Routes.routes['/$name'](context);
            },
            transitionDuration: Duration(seconds: 0),
          ),
        );
      },
    );
  }
}

enum BackendBottomNavs { spreadsheet, analysis, menu, stock, customer }
