import 'package:flutter/material.dart';
import 'package:possystem/caches/sharedpref/shared_preference_helper.dart';
import 'package:possystem/components/index.dart';

class ThemeProvider extends ChangeNotifier {
  // shared pref object
  SharedPreferenceHelper _sharedPrefsHelper;

  bool _isDarkModeOn = false;

  ThemeProvider() {
    _sharedPrefsHelper = SharedPreferenceHelper();
  }

  bool get isDarkModeOn {
    _sharedPrefsHelper.isDarkMode.then((statusValue) {
      _isDarkModeOn = statusValue;
    });

    return _isDarkModeOn;
  }

  ThemeMode get mode {
    return isDarkModeOn ? ThemeMode.dark : ThemeMode.light;
  }

  void updateTheme(bool isDarkModeOn) {
    _sharedPrefsHelper.changeTheme(isDarkModeOn);
    _sharedPrefsHelper.isDarkMode.then((darkModeStatus) {
      _isDarkModeOn = darkModeStatus;
    });

    notifyListeners();
  }

  Widget text(BuildContext context, text) {
    var component = Component(context);
    return component.text(text);
  }

  Widget component(BuildContext context, String method) {
    var component = Component(context);

    switch(method) {
      case 'spinner':
        return component.spinner();
      default:
        return Center(child: null,);
    }
  }
}
