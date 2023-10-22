import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/home/features_page.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_auth.dart';
import '../../mocks/mock_cache.dart';
import '../../services/auth_test.mocks.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Features Page', () {
    Widget buildApp() {
      final setting = SettingsProvider(SettingsProvider.allSettings);

      return ChangeNotifierProvider.value(
        value: setting,
        builder: (_, __) => const MaterialApp(home: FeaturesPage()),
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

      expect(find.text('HI，TestUser'), findsOneWidget);

      // sign out
      await tester.tap(find.byKey(const Key('feature.sign_out')));
      controller.add(null);
      await tester.pumpAndSettle();

      verify(auth.signOut());
      expect(find.byKey(const Key('google_sign_in')), findsOneWidget);
    });

    testWidgets('select theme', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text(S.settingThemeTypes('system')), findsOneWidget);

      await tester.tap(find.byKey(const Key('feature.theme')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.settingThemeTypes('dark')));
      await tester.pumpAndSettle();

      expect(find.text(S.settingThemeTypes('dark')), findsOneWidget);
      verify(cache.set(any, 2));
    });

    testWidgets('select language', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('繁體中文'), findsOneWidget);

      await tester.tap(find.byKey(const Key('feature.language')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
      verify(cache.set(any, 'en'));
    });

    testWidgets('select outlook_order', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text(S.settingOrderOutlookTypes('slidingPanel')),
          findsOneWidget);

      await tester.tap(find.byKey(const Key('feature.outlook_order')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.settingOrderOutlookTypes('singleView')));
      await tester.pumpAndSettle();

      expect(
          find.text(S.settingOrderOutlookTypes('singleView')), findsOneWidget);
      verify(cache.set(any, 1));
    });

    testWidgets('select checkout_warning', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(
          find.text(S.settingCheckoutWarningTypes('showAll')), findsOneWidget);

      await tester.tap(find.byKey(const Key('feature.checkout_warning')));
      await tester.pumpAndSettle();

      await tester
          .tap(find.text(S.settingCheckoutWarningTypes('onlyNotEnough')));
      await tester.pumpAndSettle();

      expect(find.text(S.settingCheckoutWarningTypes('onlyNotEnough')),
          findsOneWidget);
      verify(cache.set(any, 1));
    });

    testWidgets('slide order product count', (tester) async {
      await tester.pumpWidget(buildApp());

      final finder = find.byKey(const Key('feature.order_product_count'));
      await tester.drag(finder, const Offset(-500, 0));
      await tester.pumpAndSettle();

      verify(cache.set(any, 0));

      await tester.drag(finder, const Offset(1500, 0));
      await tester.pumpAndSettle();

      verify(cache.set(any, 5));
    });

    testWidgets('switch awake_ordering', (tester) async {
      tester.view.physicalSize = const Size(1000, 3000);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('feature.awake_ordering')));
      await tester.pumpAndSettle();

      verify(cache.set(any, false));
    });

    testWidgets('switch collect_events', (tester) async {
      tester.view.physicalSize = const Size(1000, 3000);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('feature.collect_events')));
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
