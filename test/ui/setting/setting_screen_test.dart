import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/ui/setting/setting_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/providers.dart';

void main() {
  testWidgets('should show selected preference', (tester) async {
    when(language.locale).thenReturn(Locale('zh', 'TW'));
    when(theme.mode).thenReturn(ThemeMode.dark);

    await tester.pumpWidget(MaterialApp(
      home: MultiProvider(providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: theme),
        ChangeNotifierProvider<LanguageProvider>.value(value: language),
      ], child: SettingScreen()),
    ));

    expect(find.text('setting.theme.dark'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);
  });

  setUpAll(() {
    initializeProviders();
  });
}
