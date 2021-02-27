import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/ui/menu/menu_screen.dart';

class MenuTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('主頁'),
            trailing: CupertinoButton(
              onPressed: () {
                debugPrint('Back button tapped');
              },
              child: Icon(Icons.shopping_bag_sharp),
              padding: EdgeInsets.zero,
            ),
          ),
          child: SafeArea(child: MenuScreen()),
        );
      },
    );
  }
}
