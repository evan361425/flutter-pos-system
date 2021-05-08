import 'package:flutter/material.dart';
import 'package:possystem/components/card_tile.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:provider/provider.dart';

class LanguageModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = context.read<LanguageProvider>().locale;
    final local = Local.of(context);

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
            title: Text(local.t('setting.language.${locale.toString()}')),
            trailing: current == locale ? Icon(Icons.check_sharp) : null,
            onTap: () => Navigator.of(context).pop(locale),
          );
        },
        itemCount: LanguageProvider.supports.length,
      ),
    );
  }
}
