import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/setup_menu.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';

import '../mocks/mock_storage.dart';

void main() {
  group('Setup Menu', () {
    test('Should add once', () async {
      when(storage.add(any, any, any)).thenAnswer((_) => Future.value());

      await helpSetupMenu();
      verify(storage.add(any, any, any));

      await helpSetupMenu();
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
