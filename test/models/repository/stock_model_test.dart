import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:possystem/models/stock/ingredient_model.dart';

import '../../mocks/mock_storage.dart' as storage;

@GenerateMocks([IngredientModel])
void main() {
  setUpAll(() {
    storage.before();
  });

  tearDownAll(() {
    storage.after();
  });
}
