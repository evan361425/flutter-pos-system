import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/ui/setting/widgets/language_modal.dart';
import 'package:provider/provider.dart';

import '../../../mocks/providers.dart';

void main() {
  testWidgets('only change language if need', (tester) async {
    when(language.locale).thenReturn(Locale('zh', 'TW'));
    when(language.setLocale(any)).thenAnswer((_) => Future.value());

    await tester.pumpWidget(MaterialApp(
      home: MultiProvider(providers: [
        ChangeNotifierProvider<LanguageProvider>.value(value: language),
      ], child: LanguageModal()),
    ));

    await tester.tap(find.text('繁體中文'));
    await tester.pumpAndSettle();

    verifyNever(language.setLocale(any));

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    verify(language.setLocale(any));
  });

  setUpAll(() {
    initializeProviders();
  });
}
