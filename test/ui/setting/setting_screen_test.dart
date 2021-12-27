import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/settings/order_outlook_setting.dart';
import 'package:possystem/settings/order_product_axis_count_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/settings/theme_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/setting/setting_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Setting Screen', () {
    Future<void> buildApp(WidgetTester tester) {
      final setting = SettingsProvider([
        ThemeSetting(),
        LanguageSetting(),
        OrderOutlookSetting(),
        OrderAwakeningSetting(),
        OrderProductAxisCountSetting(),
        CurrencySetting(),
      ]);

      return tester.pumpWidget(ChangeNotifierProvider.value(
        value: setting,
        builder: (_, __) => const MaterialApp(home: SettingScreen()),
      ));
    }

    testWidgets('select theme', (tester) async {
      await buildApp(tester);

      expect(find.text(S.settingThemeTypes('system')), findsOneWidget);

      await tester.tap(find.byKey(const Key('setting.theme')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.settingThemeTypes('dark')));
      await tester.pumpAndSettle();

      expect(find.text(S.settingThemeTypes('dark')), findsOneWidget);
    });

    testWidgets('select language', (tester) async {
      await buildApp(tester);

      expect(find.text('繁體中文'), findsOneWidget);

      await tester.tap(find.byKey(const Key('setting.language')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('select outlook_order', (tester) async {
      await buildApp(tester);

      expect(find.text(S.settingOrderOutlookTypes('slidingPanel')),
          findsOneWidget);

      await tester.tap(find.byKey(const Key('setting.outlook_order')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.settingOrderOutlookTypes('singleView')));
      await tester.pumpAndSettle();

      expect(
          find.text(S.settingOrderOutlookTypes('singleView')), findsOneWidget);
    });

    testWidgets('switch awake_ordering', (tester) async {
      await buildApp(tester);

      await tester.tap(find.byKey(const Key('setting.awake_ordering')));
      await tester.pumpAndSettle();

      verify(cache.set(any, false));
    });

    testWidgets('slide order product count', (tester) async {
      await buildApp(tester);

      final finder = find.byKey(const Key('setting.order_product_count'));
      await tester.drag(finder, const Offset(-500, 0));
      await tester.pumpAndSettle();

      verify(cache.set(any, 0));

      await tester.drag(finder, const Offset(1500, 0));
      await tester.pumpAndSettle();

      verify(cache.set(any, 5));
    });

    setUp(() {
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
    });

    setUpAll(() {
      initializeCache();
      initializeTranslator();
    });
  });
}
