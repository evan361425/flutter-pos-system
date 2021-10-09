import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/ui/setting/setting_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_providers.dart';

void main() {
  testWidgets('should show selected preference', (tester) async {
    when(language.locale).thenReturn(Locale('zh', 'TW'));
    when(theme.mode).thenReturn(ThemeMode.dark);
    when(cache.get(Caches.feature_awake_provider)).thenReturn(false);
    when(cache.get(Caches.outlook_order)).thenReturn(1);
    when(cache.set(any, any)).thenAnswer((_) => Future.value(true));

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
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    // test switch
    LOG_LEVEL = 0;
    await tester.tap(find.byKey(Key('setting.feature.awake_ordering')));
    await tester.pump();

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    // test theme
    await tester.tap(find.byKey(Key('setting.theme')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('light'));
    await tester.pumpAndSettle();
    // test language
    await tester.tap(find.byKey(Key('setting.language')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    // test outlook order
    await tester.tap(find.byKey(Key('setting.outlook_order')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('酷炫面板'));
    await tester.pumpAndSettle();
  });

  setUpAll(() {
    initializeCache();
    initializeProviders();
  });
}
