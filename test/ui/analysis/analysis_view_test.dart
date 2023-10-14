import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/ui/analysis/analysis_view.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Analysis View', () {
    Widget buildApp({themeMode = ThemeMode.light}) {
      when(cache.get(any)).thenReturn(null);
      // disable tutorial
      when(cache.get(
        argThat(predicate<String>((key) => key.startsWith('tutorial.'))),
      )).thenReturn(true);
      final settings = SettingsProvider([
        LanguageSetting(),
        CurrencySetting(),
      ]);

      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: Seller()),
        ],
        builder: (_, __) => MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) {
                  return const Scaffold(body: AnalysisView());
                },
                routes: Routes.routes,
              ),
            ],
          ),
        ),
      );
    }

    void mockGetMetrics() {
      when(database.query(
        Seller.orderTable,
        columns: argThat(contains('COUNT(*) count'), named: 'columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([{}]));
    }

    testWidgets('navigate to history', (tester) async {
      mockGetMetrics();
      when(database.query(
        Seller.orderTable,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
        limit: argThat(equals(10), named: 'limit'),
        offset: anyNamed('offset'),
        join: anyNamed('join'),
        groupBy: anyNamed('groupBy'),
      )).thenAnswer((_) => Future.value([]));
      when(database.query(
        any,
        columns: argThat(equals(['t.day', 'COUNT(*) c']), named: 'columns'),
        groupBy: argThat(equals('t.day'), named: 'groupBy'),
        whereArgs: anyNamed('whereArgs'),
        escapeTable: false,
      )).thenAnswer((_) => Future.value([]));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('anal.history')));
      await tester.pumpAndSettle();
    });

    setUpAll(() {
      initializeCache();
      initializeDatabase();
      initializeTranslator();
    });
  });
}
