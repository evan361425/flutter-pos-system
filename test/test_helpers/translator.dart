import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:possystem/translator.dart';

var _initialized = false;

void initializeTranslator() {
  if (!_initialized) {
    _initialized = true;
    S = AppLocalizationsEn();
    Intl.systemLocale = S.localeName;
    Intl.defaultLocale = S.localeName;
    initializeDateFormatting(S.localeName);
  }
}
