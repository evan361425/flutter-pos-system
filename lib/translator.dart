import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:possystem/l10n/gen/app_localizations.dart';
import 'package:possystem/l10n/gen/app_localizations_en.dart';

ValueNotifier<AppLocalizations?> localeNotifier = ValueNotifier(null);
AppLocalizations S = setAppLocalizations(AppLocalizationsEn());

AppLocalizations setAppLocalizations(AppLocalizations localizations) {
  S = localizations;
  localeNotifier.value = localizations;
  Intl.systemLocale = localizations.localeName;
  Intl.defaultLocale = localizations.localeName;
  initializeDateFormatting(localizations.localeName);
  return localizations;
}
