import 'package:mockito/annotations.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';

import 'mock_repos.mocks.dart';

final replenisher = MockReplenisher();
final cart = MockCart();
final cashier = MockCashier();
final menu = MockMenu();
final seller = MockSeller();
final quantities = MockQuantities();
final stock = MockStock();

@GenerateMocks([
  Cart,
  Cashier,
  Menu,
  Seller,
  Quantities,
  Replenisher,
  Stock,
])
void _initialize() {
  Cart.instance = cart;
  Cashier.instance = cashier;
  Menu.instance = menu;
  Seller.instance = seller;
  Quantities.instance = quantities;
  Replenisher.instance = replenisher;
  Stock.instance = stock;
  _finished = true;
}

var _finished = false;
void initializeRepos() {
  if (!_finished) {
    _initialize();
  }
}
