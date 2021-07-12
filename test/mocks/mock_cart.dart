import 'package:mockito/annotations.dart';
import 'package:possystem/models/repository/cart_model.dart';

import 'mock_cart.mocks.dart';

final cart = MockCartModel();

@GenerateMocks([CartModel])
void _initialize() {
  _finished = true;
  CartModel.instance = cart;
}

var _finished = false;
void initializeCart() {
  if (!_finished) {
    _initialize();
  }
}
