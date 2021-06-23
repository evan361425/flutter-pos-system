import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprintf/sprintf.dart';

class Translator {
  static final Translator instance = Translator._constructor();

  static const LocalizationsDelegate<Translator> delegate =
      _LocalizationsDelegate();

  Map<String, String> _data = {};

  //This is the static member for allowing simple access to the delegate
  // from the MaterialApp
  Translator._constructor();

  Future<void> load(Locale locale) async {
    final fileName = 'lang/$locale/app.g.json';
    final contents = await rootBundle.loadString(fileName);
    final Map<String, dynamic> data = jsonDecode(contents);
    _data = data.cast<String, String>();
  }

  String translate(String key, [List<dynamic>? args]) {
    final value = _data[key] ?? key;
    return args == null ? value : sprintf(value, args);
  }

  static String t(String key, [List<dynamic>? args]) {
    return instance.translate(key, args);
  }
}

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be gotten in an AppLocalizations object
class _LocalizationsDelegate extends LocalizationsDelegate<Translator> {
  const _LocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  // already set in [LanguageProvider.localResolutionCallback]
  @override
  Future<Translator> load(Locale locale) async {
    await Translator.instance.load(locale);
    return Translator.instance;
  }

  @override
  bool shouldReload(_LocalizationsDelegate old) => false;
}
