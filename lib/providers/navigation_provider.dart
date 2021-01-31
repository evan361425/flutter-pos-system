import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/index.dart' as Menu;
import 'package:possystem/ui/setting/setting_screen.dart';

class NavigationProvider with ChangeNotifier {
  String _page = 'menu';

  Widget get body {
    if (_page == 'menu') {
      return Menu.HomeScreen();
    } else if (_page == 'setting') {
      return SettingScreen();
    } else {
      return Text('empty screen');
    }
  }

  String get page => _page;

  void set page(String navigation) {
    _page = navigation;
    notifyListeners();
  }
}