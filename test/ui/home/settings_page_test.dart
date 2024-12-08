import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/home/settings_page.dart';

import '../../mocks/mock_auth.dart';
import '../../mocks/mock_cache.dart';
import '../../services/auth_test.mocks.dart';
import '../../test_helpers/firebase_mocker.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Settings Page', () {
    Widget buildApp() {
      return MaterialApp.router(
        locale: LanguageSetting.instance.language.locale,
        routerConfig: GoRouter(
          navigatorKey: Routes.rootNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const Scaffold(body: SettingsPage()),
            ),
            ...Routes.getDesiredRoute(0).routes,
          ],
        ),
      );
    }

    testWidgets('Auth sign in and out', (tester) async {
      final user = MockUser();
      final controller = StreamController<MockUser?>();
      when(user.displayName).thenReturn('TestUser');
      when(auth.authStateChanges()).thenAnswer((_) => controller.stream);
      when(auth.signOut()).thenAnswer((_) => Future.value());

      await tester.pumpWidget(buildApp());

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

      expect(find.text(S.settingWelcome('TestUser')), findsOneWidget);

      // sign out
      await tester.tap(find.byKey(const Key('feature.sign_out')));
      controller.add(null);
      await tester.pumpAndSettle();

      verify(auth.signOut());
      expect(find.byKey(const Key('google_sign_in')), findsOneWidget);
    });

    testWidgets('select theme', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text(S.settingThemeName('system')), findsOneWidget);

      await tester.tap(find.byKey(const Key('feature.theme')));
      await tester.pumpAndSettle();

      when(cache.get('theme')).thenReturn(ThemeMode.dark.index);

      await tester.tap(find.text(S.settingThemeName('dark')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pop')));
      await tester.pumpAndSettle();

      expect(find.text(S.settingThemeName('dark')), findsOneWidget);
      verify(cache.set(any, ThemeMode.dark.index));
    });

    testWidgets('select language', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('English'), findsOneWidget);

      await tester.tap(find.byKey(const Key('feature.language')));
      await tester.pumpAndSettle();

      when(cache.get('language')).thenReturn('zh_TW');

      await tester.tap(find.text('繁體中文'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pop')));
      await tester.pumpAndSettle();

      expect(find.text('繁體中文'), findsOneWidget);
      verify(cache.set(any, 'zh_TW'));
    });

    testWidgets('select checkout_warning', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text(S.settingCheckoutWarningName('showAll')), findsOneWidget);

      await tester.tap(find.byKey(const Key('feature.checkout_warning')));
      await tester.pumpAndSettle();

      when(cache.get('feat.cashierWarning')).thenReturn(1);

      await tester.tap(find.text(S.settingCheckoutWarningName('onlyNotEnough')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pop')));
      await tester.pumpAndSettle();

      expect(find.text(S.settingCheckoutWarningName('onlyNotEnough')), findsOneWidget);
      verify(cache.set(any, 1));
    });

    testWidgets('switch awake_ordering', (tester) async {
      await tester.pumpWidget(buildApp());

      final finder = find.byKey(const Key('feature.order_awakening'));
      await tester.scrollUntilVisible(find.byKey(const Key('feature.collect_events')), 200);

      await tester.tap(finder);
      await tester.pumpAndSettle();

      verify(cache.set(any, false));
    });

    testWidgets('switch collect_events', (tester) async {
      setupFirebaseAnalyticsMocks();
      await Firebase.initializeApp();
      await tester.pumpWidget(buildApp());

      final finder = find.byKey(const Key('feature.collect_events'));
      await tester.scrollUntilVisible(finder, 200);

      await tester.tap(finder);
      await tester.pumpAndSettle();

      verify(cache.set(any, false));
    });

    setUp(() {
      reset(cache);
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
      when(cache.get(any)).thenReturn(null);
      SettingsProvider.instance.initialize();
    });
  });
}
