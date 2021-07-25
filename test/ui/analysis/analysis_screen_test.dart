import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/ui/analysis/analysis_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_repos.dart';
import '../../mocks/mock_providers.dart';

void main() {
  testWidgets('should load count once in start', (tester) async {
    final now = DateTime.now();
    when(seller.getCountBetween(
      argThat(predicate<DateTime>((arg) => arg.isBefore(now))),
      argThat(predicate<DateTime>((arg) => arg.isAfter(now))),
    )).thenAnswer((_) => Future.value({}));
    when(language.locale).thenReturn(Locale('zh', 'TW'));

    await tester.pumpWidget(MaterialApp(
      locale: Locale('zh', 'TW'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<LanguageProvider>.value(
            value: language,
          )
        ],
        builder: (_, __) => AnalysisScreen(),
      ),
    ));
  });

  setUpAll(() {
    initializeRepos();
  });
}
