import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/ui/analysis/widgets/calendar_wrapper.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mock_providers.dart';

void main() {
  Widget wrapCalendar(CalendarWrapper calendar) {
    when(language.locale).thenReturn(Locale('zh', 'TW'));

    return MaterialApp(
      locale: Locale('zh', 'TW'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<LanguageProvider>.value(value: language)
        ],
        builder: (_, __) => Material(child: calendar),
      ),
    );
  }

  testWidgets('should change to week format on select day', (tester) async {
    final now = DateTime(2021, 6, 25);

    await tester.pumpWidget(wrapCalendar(CalendarWrapper(
        searchCountInMonth: (_) => Future.value({}),
        handleDaySelected: (_) {},
        initialDate: now,
        isPortrait: true)));

    expect(find.text('23'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);

    await tester.tap(find.text('23'));
    await tester.pumpAndSettle();

    expect(find.text('16'), findsNothing);
  });
  testWidgets('should load month data once', (tester) async {
    final now = DateTime(2021, 6, 25);
    var loadCount = 0;

    await tester.pumpWidget(wrapCalendar(CalendarWrapper(
        searchCountInMonth: (_) => Future.value({now: loadCount++}),
        handleDaySelected: (_) {},
        initialDate: now,
        isPortrait: true)));

    expect(find.text('31'), findsOneWidget);
    expect(loadCount, equals(1));

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(loadCount, equals(2));

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(loadCount, equals(2));
  });

  setUpAll(() {
    initializeProviders();
  });
}
