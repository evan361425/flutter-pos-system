import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/ui/setting/widgets/theme_modal.dart';
import 'package:provider/provider.dart';

import '../../../mocks/providers.dart';

void main() {
  testWidgets('only change theme if need', (tester) async {
    when(theme.mode).thenReturn(ThemeMode.dark);
    when(theme.setMode(any)).thenAnswer((_) => Future.value());

    await tester.pumpWidget(MaterialApp(
      home: MultiProvider(providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: theme),
      ], child: ThemeModal()),
    ));

    await tester.tap(find.text('dark'));
    await tester.pumpAndSettle();

    verifyNever(theme.setMode(any));

    await tester.tap(find.text('light'));
    await tester.pumpAndSettle();

    verify(theme.setMode(any));
  });

  setUpAll(() {
    initializeProviders();
  });
}
