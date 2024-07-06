import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/setup_example.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';

import '../mocks/mock_storage.dart';
import '../test_helpers/translator.dart';

void main() {
  group('Setup Menu', () {
    test('Should add once', () async {
      when(storage.add(any, any, any)).thenAnswer((_) => Future.value());

      await setupExampleMenu();
      await setupExampleOrderAttrs();
      verify(storage.add(any, any, any));

      await setupExampleMenu();
      await setupExampleOrderAttrs();
      verifyNever(storage.add(any, any, any));
    });

    setUpAll(() {
      initializeStorage();
      initializeTranslator();
      Menu();
      Stock();
      Quantities();
      OrderAttributes();
    });
  });
}
