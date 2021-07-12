import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class ThemeModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(tt('setting.theme.title')),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final mode = ThemeList[index];

          return CardTile(
            title: Text(tt('setting.theme.${ThemeCode[mode]}')),
            trailing: mode == theme.mode ? Icon(Icons.check_sharp) : null,
            onTap: () {
              if (mode != theme.mode) {
                theme.setMode(mode);
              }
            },
          );
        },
        itemCount: ThemeList.length,
      ),
    );
  }

  static const ThemeList = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

  static const ThemeCode = <ThemeMode, String>{
    ThemeMode.system: 'system',
    ThemeMode.light: 'light',
    ThemeMode.dark: 'dark',
  };
}
