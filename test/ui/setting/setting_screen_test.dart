import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/ui/setting/setting_screen.dart';
import 'package:possystem/components/style/feature_switch.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_providers.dart';

void main() {
  testWidgets('should show selected preference', (tester) async {
    when(language.locale).thenReturn(Locale('zh', 'TW'));
    when(theme.mode).thenReturn(ThemeMode.dark);
    when(cache.get(Caches.feature_awake_provider)).thenReturn(false);
    when(cache.get(Caches.outlook_order)).thenReturn(1);

    await tester.pumpWidget(MaterialApp(
      home: MultiProvider(providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: theme),
        ChangeNotifierProvider<LanguageProvider>.value(value: language),
      ], child: SettingScreen()),
    ));

    expect(find.text('dark'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);
    expect(find.text('經典模式'), findsOneWidget);

    // check widget
    final awateOrdering = find.byKey(Key('setting.feature.awate_ordering'));
    expect(tester.widget<FeatureSwitch>(awateOrdering).value, false);
  });

  setUpAll(() {
    initializeCache();
    initializeProviders();
  });
}
