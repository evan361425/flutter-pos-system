import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = context.read<ThemeProvider>().mode;

    return Scaffold(
      appBar: AppBar(
        title: Text('調色盤'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final theme = ThemeList[index];

          return CardTile(
            title: Text(ThemeName[theme]!),
            trailing: current == theme ? Icon(Icons.check_sharp) : null,
            onTap: () => Navigator.of(context).pop(theme),
          );
        },
        itemCount: ThemeList.length,
      ),
    );
  }

  static const ThemeList = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

  static const ThemeName = <ThemeMode, String>{
    ThemeMode.system: '跟隨系統',
    ThemeMode.light: '日光模式',
    ThemeMode.dark: '暗色模式',
  };
}
