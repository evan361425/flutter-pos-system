import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:possystem/translator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_zh.dart';

var _initialized = false;

void initializeTranslator() {
  if (!_initialized) {
    _initialized = true;
    S = AppLocalizationsZh();
    currentLocale = const Locale('zh');
    Intl.systemLocale = S.localeName;
    Intl.defaultLocale = S.localeName;
    initializeDateFormatting(S.localeName);
  }
}
