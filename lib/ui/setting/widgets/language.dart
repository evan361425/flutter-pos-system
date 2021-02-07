import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:provider/provider.dart';

class LanguagePopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final current = language.locale;

    return PopupMenuButton<Locale>(
      icon: Icon(Icons.language),
      onSelected: (Locale selected) => language.locale = selected,
      itemBuilder: (BuildContext context) => _buildItem(context, current),
    );
  }

  List<PopupMenuEntry> _buildItem(BuildContext context, Locale current) {
    return LanguageProvider.supports.map((locale) {
      return PopupMenuItem(
        value: locale,
        enabled: locale.languageCode != current.languageCode &&
            locale.countryCode != current.countryCode,
        child: Text(
          Local.of(context).translate('setting.language.$locale'),
        ),
      );
    }).toList();
  }
}

enum LanguagesActions { english, chinese }
