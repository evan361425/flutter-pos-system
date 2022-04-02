import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/debug/setup_menu.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';

import '../mocks/mock_storage.dart';

void main() {
  group('Setup Menu in DEBUG mode', () {
    test('Should add once', () async {
      when(storage.add(any, any, any)).thenAnswer((_) => Future.value());

      await debugSetupMenu();
      verify(storage.add(any, any, any));

      await debugSetupMenu();
      verifyNever(storage.add(any, any, any));
    });

    setUpAll(() {
      initializeStorage();
      Menu();
      Stock();
      Quantities();
    });
  });
}
