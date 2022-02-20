import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/settings/theme_setting.dart';
import 'package:provider/provider.dart';

import 'mocks/mock_cache.dart';

void main() {
  setupFirebaseAuthMocks();

  testWidgets('should bind model to menu', (tester) async {
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
        child: _TestChild(),
      ),
    );

    await tester.pumpWidget(app);
  });

  setUpAll(() {
    initializeCache();
  });
}

// https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_auth/firebase_auth/test/mock.dart
void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': {},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return {
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {},
      };
    }

    return null;
  });
}

class _TestChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
