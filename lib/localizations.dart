import 'dart:async';
import 'package:possystem/providers/language_provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Local {
  final Locale locale;

  Local(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static Local of(BuildContext context) {
    return Localizations.of<Local>(context, Local);
  }

  //This is the static member for allowing simple access to the delegate
  // from the MaterialApp
  static const LocalizationsDelegate<Local> delegate =
      _AppLocalizationsDelegate();

  static const List<String> files = ['app', 'setting', 'auth', 'menu'];

  final Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    var countryCode =
        locale.countryCode == null ? '' : '-${locale.countryCode}';
    var folder = 'lang/${locale.languageCode}$countryCode';
    // Load the language YAML file from the "lang" folder
    for (var filename in files) {
      var raw = await rootBundle.loadString('$folder/$filename.yaml');
      var prefix = filename == 'app' ? '' : '$filename.';
      _dynamicLoadMap(prefix, loadYaml(raw));
    }

    return true;
  }

  String t(String key) {
    return translate(key);
  }

  String tf(String key, List<dynamic> data) {
    return translatef(key, data);
  }

  // This method will be called from every widgets which needs a localized text
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  String translatef(String key, List<dynamic> data) {
    return sprintf(translate(key), data);
  }

  void _dynamicLoadMap(String prefix, YamlMap data) {
    data.forEach((key, value) {
      if (value is YamlMap) {
        _dynamicLoadMap('$prefix$key.', value);
      } else {
        _localizedStrings[prefix + key] = value.toString();
      }
    });
  }
}

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be gotten in an AppLocalizations object
class _AppLocalizationsDelegate extends LocalizationsDelegate<Local> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return LanguageProvider.supports
        .map((Locale each) => each.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<Local> load(Locale locale) async {
    // AppLocalizations class is where the YAML loading actually runs
    var localizations = Local(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
