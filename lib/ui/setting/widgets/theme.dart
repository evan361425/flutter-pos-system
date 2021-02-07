import 'package:flutter/material.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: Theme.of(context).appBarTheme.color,
      value: context.watch<ThemeProvider>().isDarkModeOn,
      onChanged: (booleanValue) {
        final theme = context.read<ThemeProvider>();
        theme.updateTheme(booleanValue);
      },
    );
  }
}
