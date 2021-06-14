import 'package:mockito/annotations.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/repository/order_repo.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/services/storage.dart';

import 'mocks.mocks.dart';

final cache = MockCache();
final storage = MockStorage();
final stock = MockStockModel();
final menu = MockMenuModel();
final batches = MockStockBatchRepo();
final quantities = MockQuantityRepo();
final orders = MockOrderRepo();

@GenerateMocks([
  Cache,
  Storage,
  StockModel,
  MenuModel,
  StockBatchRepo,
  QuantityRepo,
  OrderRepo,
])
void _initialize() {
  Storage.instance = storage;
  StockModel.instance = stock;
  Cache.instance = cache;
  MenuModel.instance = menu;
  StockBatchRepo.instance = batches;
  QuantityRepo.instance = quantities;
  OrderRepo.instance = orders;
  _finished = true;
}

var _finished = false;
void initialize() {
  if (!_finished) {
    _initialize();
  }
}
