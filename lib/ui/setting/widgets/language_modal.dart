import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:provider/provider.dart';

class LanguageModal extends StatefulWidget {
  @override
  _LanguageModalState createState() => _LanguageModalState();

  static const LanguageName = <String, String>{
    'zh_TW': '繁體中文',
    'en_US': 'English',
  };

  static String getLanguageName(Locale locale) {
    return LanguageName[locale.toString()] ?? 'unknown';
  }
}

class _LanguageModalState extends State<LanguageModal> {
  @override
  Widget build(BuildContext context) {
    final language = context.read<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('語言'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final locale = LanguageProvider.supports[index];

          return CardTile(
            title: Text(LanguageModal.LanguageName[locale.toString()]!),
            trailing:
                language.locale == locale ? Icon(Icons.check_sharp) : null,
            onTap: () async {
              if (locale != language.locale) {
                await language.setLocale(locale);
              }
            },
          );
        },
        itemCount: LanguageProvider.supports.length,
      ),
    );
  }
}
