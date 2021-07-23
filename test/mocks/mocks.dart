import 'package:mockito/annotations.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/repository/order_repo.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/services/storage.dart';

import 'mockito/mock_stock_batch_repo.dart';
import 'mockito/mock_stock_modal.dart';
import 'mocks.mocks.dart';

final batches = MockStockBatchRepo();
final cache = MockCache();
final cart = MockCartModel();
final cashier = MockCashier();
final menu = MockMenuModel();
final orders = MockOrderRepo();
final quantities = MockQuantityRepo();
final storage = MockStorage();
final stock = MockStockModel();

@GenerateMocks([
  Cache,
  Storage,
  MenuModel,
  OrderRepo,
  QuantityRepo,
  CartModel,
  Cashier,
])
void _initialize() {
  Cache.instance = cache;
  CartModel.instance = cart;
  Cashier.instance = cashier;
  MenuModel.instance = menu;
  OrderRepo.instance = orders;
  QuantityRepo.instance = quantities;
  StockBatchRepo.instance = batches;
  StockModel.instance = stock;
  Storage.instance = storage;
  _finished = true;
}

var _finished = false;
void initialize() {
  if (!_finished) {
    _initialize();
  }
}
