import 'package:mockito/annotations.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/repository/order_repo.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/repository/stock_model.dart';

import 'mock_repos.mocks.dart';

final batches = MockStockBatchRepo();
final cart = MockCartModel();
final cashier = MockCashier();
final menu = MockMenuModel();
final orders = MockOrderRepo();
final quantities = MockQuantityRepo();
final stock = MockStockModel();

@GenerateMocks([
  CartModel,
  Cashier,
  MenuModel,
  OrderRepo,
  QuantityRepo,
  StockBatchRepo,
  StockModel,
])
void _initialize() {
  CartModel.instance = cart;
  Cashier.instance = cashier;
  MenuModel.instance = menu;
  OrderRepo.instance = orders;
  QuantityRepo.instance = quantities;
  StockBatchRepo.instance = batches;
  StockModel.instance = stock;
  _finished = true;
}

var _finished = false;
void initializeRepos() {
  if (!_finished) {
    _initialize();
  }
}
