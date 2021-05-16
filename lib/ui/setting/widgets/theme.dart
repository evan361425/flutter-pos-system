import 'package:flutter/material.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Switch(
      activeColor: Theme.of(context).appBarTheme.color,
      value: theme.darkMode,
      onChanged: (value) => theme.setDarkMode(value),
    );
  }
}
