import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/app.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:provider/provider.dart';

import 'mocks/mock_cache.dart';
import 'test_helpers/firebase_mocker.dart';

void main() {
  testWidgets('MyApp should execute onGenerateTitle', (tester) async {
    when(cache.get(any)).thenReturn(null);
    when(cache.get('tutorial.home.menu')).thenReturn(true);
    when(cache.get('tutorial.home.exporter')).thenReturn(true);
    when(cache.get('tutorial.home.order_attr')).thenReturn(true);
    await Firebase.initializeApp();

    final app = MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: SettingsProvider.instance),
        ChangeNotifierProvider.value(value: Menu()),
        ChangeNotifierProvider.value(value: OrderAttributes()),
        ChangeNotifierProvider.value(value: Printers()),
      ],
      builder: (_, __) => const App(),
    );

    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 50));
  });

  setUpAll(() {
    initializeCache();
    setupFirebaseAuthMocks();
  });
}
