import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

AppLocalizations S = setAppLocalizations(AppLocalizationsEn());

AppLocalizations setAppLocalizations(AppLocalizations localizations) {
  S = localizations;
  Intl.systemLocale = localizations.localeName;
  Intl.defaultLocale = localizations.localeName;
  initializeDateFormatting(localizations.localeName);
  return localizations;
}
