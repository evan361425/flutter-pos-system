import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/settings/theme_setting.dart';
import 'package:provider/provider.dart';

import 'mocks/mock_cache.dart';
import 'test_helpers/firebase_mocker.dart';

void main() {
  testWidgets('should execute onGenerateTitle', (tester) async {
    when(cache.get(any)).thenReturn(null);
    await Firebase.initializeApp();

    final settings = SettingsProvider([
      ThemeSetting(),
      LanguageSetting(),
    ]);
    final app = ChangeNotifierProvider.value(
      value: settings,
      builder: (_, __) => MyApp(
        settings: settings,
        child: Container(),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  });

  setUpAll(() {
    initializeCache();
    setupFirebaseAuthMocks();
  });
}
