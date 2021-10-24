import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/ui/setting/setting_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';

void main() {
  group('Setting Screen', () {
    Future<void> buildApp(WidgetTester tester) {
      final theme = ThemeProvider();
      final language = LanguageProvider();

      theme.initialize();
      language.initialize();

      return tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: theme),
          ChangeNotifierProvider<LanguageProvider>.value(value: language),
        ],
        builder: (_, __) => MaterialApp(home: SettingScreen()),
      ));
    }

    testWidgets('select theme', (tester) async {
      await buildApp(tester);

      expect(find.text('system'), findsOneWidget);

      await tester.tap(find.byKey(Key('setting.theme')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('dark'));
      await tester.pumpAndSettle();

      expect(find.text('dark'), findsOneWidget);
    });

    testWidgets('select language', (tester) async {
      await buildApp(tester);

      expect(find.text('繁體中文'), findsOneWidget);

      await tester.tap(find.byKey(Key('setting.language')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('select outlook_order', (tester) async {
      await buildApp(tester);

      expect(find.text('酷炫面板'), findsOneWidget);

      await tester.tap(find.byKey(Key('setting.outlook_order')));
      await tester.pumpAndSettle();

      when(cache.get(Caches.outlook_order)).thenReturn(1);

      await tester.tap(find.text('經典模式'));
      await tester.pumpAndSettle();

      expect(find.text('經典模式'), findsOneWidget);
    });

    testWidgets('select awake_ordering', (tester) async {
      await buildApp(tester);

      await tester.tap(find.byKey(Key('setting.feature.awake_ordering')));
      await tester.pumpAndSettle();

      verify(cache.set(any, false));
    });

    setUp(() {
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
    });

    setUpAll(() {
      initializeCache();
    });
  });
}
