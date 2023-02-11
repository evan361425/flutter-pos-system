import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/setting/setting_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_auth.dart';
import '../../mocks/mock_cache.dart';
import '../../services/auth_test.mocks.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Setting Screen', () {
    Future<void> buildApp(WidgetTester tester) {
      final setting = SettingsProvider(SettingsProvider.allSettings);

      return tester.pumpWidget(ChangeNotifierProvider.value(
        value: setting,
        builder: (_, __) => const MaterialApp(home: SettingScreen()),
      ));
    }

    testWidgets('Auth sign in and out', (tester) async {
      final user = MockUser();
      final controller = StreamController<MockUser?>();
      when(user.displayName).thenReturn('TestUser');
      when(auth.authStateChanges()).thenAnswer((_) => controller.stream);
      when(auth.signOut()).thenAnswer((_) => Future.value());

      await buildApp(tester);

      // signin failed
      when(auth.signIn()).thenAnswer((_) => Future.error('QQ'));
      await tester.tap(find.byKey(const Key('google_sign_in')));
      await tester.pumpAndSettle();

      verify(auth.signIn());
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('QQ'), findsOneWidget);

      // signin success
      when(auth.signIn()).thenAnswer((_) => Future.value(true));
      await tester.tap(find.byKey(const Key('google_sign_in')));
      await tester.pumpAndSettle();

      verify(auth.signIn());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.add(user);
      await tester.pumpAndSettle();

      expect(find.text('HI，TestUser'), findsOneWidget);

      // sign out
      await tester.tap(find.byKey(const Key('setting.sign_out')));
      controller.add(null);
      await tester.pumpAndSettle();

      verify(auth.signOut());
      expect(find.byKey(const Key('google_sign_in')), findsOneWidget);
    });

    testWidgets('select theme', (tester) async {
      await buildApp(tester);

      expect(find.text(S.settingThemeTypes('system')), findsOneWidget);

      await tester.tap(find.byKey(const Key('setting.theme')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.settingThemeTypes('dark')));
      await tester.pumpAndSettle();

      expect(find.text(S.settingThemeTypes('dark')), findsOneWidget);
      verify(cache.set(any, 2));
    });

    testWidgets('select language', (tester) async {
      await buildApp(tester);

      expect(find.text('繁體中文'), findsOneWidget);

      await tester.tap(find.byKey(const Key('setting.language')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
      verify(cache.set(any, 'en'));
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
      verify(cache.set(any, 1));
    });

    testWidgets('select cashier_warning', (tester) async {
      await buildApp(tester);

      expect(
          find.text(S.settingCashierWarningTypes('showAll')), findsOneWidget);

      await tester.tap(find.byKey(const Key('setting.cashier_warning')));
      await tester.pumpAndSettle();

      await tester
          .tap(find.text(S.settingCashierWarningTypes('onlyNotEnough')));
      await tester.pumpAndSettle();

      expect(find.text(S.settingCashierWarningTypes('onlyNotEnough')),
          findsOneWidget);
      verify(cache.set(any, 1));
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

    testWidgets('switch awake_ordering', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1000, 3000);
      await buildApp(tester);

      await tester.tap(find.byKey(const Key('setting.awake_ordering')));
      await tester.pumpAndSettle();

      verify(cache.set(any, false));
    });

    testWidgets('switch collect_events', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1000, 3000);
      await buildApp(tester);

      await tester.tap(find.byKey(const Key('setting.collect_events')));
      await tester.pumpAndSettle();

      verify(cache.set(any, false));
    });

    setUp(() {
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(null));
    });

    setUpAll(() {
      initializeCache();
      initializeTranslator();
      initializeAuth();

      PackageInfo.setMockInitialValues(
        installerStore: '',
        appName: 'a',
        packageName: 'b',
        version: 'c',
        buildNumber: 'd',
        buildSignature: 'e',
      );
    });
  });
}
