import 'dart:async';
import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  //This is the static member for allowing simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<String> files = [
    'app',
  ];

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    String prefix = 'lang/${locale.languageCode}/';
    // Load the language YAML file from the "lang" folder
    for(String file in files) {
      String raw = await rootBundle.loadString(prefix + file + '.yaml');

      String keyPrefix = file == 'app' ? '' : (file.split('/').join('.') + '.');
      loadYaml(raw).forEach((key, value) {
        _localizedStrings[keyPrefix + key] = value.toString();
      });
    }

    return true;
  }

  // This method will be called from every widgets which needs a localized text
  String t(String key) {
    return translate(key);
  }
  
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

}

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be gotten in an AppLocalizations object
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
