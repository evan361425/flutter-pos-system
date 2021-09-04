import 'package:mockito/annotations.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/customers.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';

import 'mock_repos.mocks.dart';

final cart = MockCart();
final cashier = MockCashier();
final customerSettings = MockCustomerSettings();
final menu = MockMenu();
final quantities = MockQuantities();
final replenisher = MockReplenisher();
final seller = MockSeller();
final stock = MockStock();

@GenerateMocks([
  Cart,
  Cashier,
  CustomerSettings,
  Menu,
  Quantities,
  Replenisher,
  Seller,
  Stock,
])
void _initialize() {
  Cart.instance = cart;
  Cashier.instance = cashier;
  CustomerSettings.instance = customerSettings;
  Menu.instance = menu;
  Quantities.instance = quantities;
  Replenisher.instance = replenisher;
  Seller.instance = seller;
  Stock.instance = stock;
  _finished = true;
}

var _finished = false;
void initializeRepos() {
  if (!_finished) {
    _initialize();
  }
}
