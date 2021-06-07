import 'package:mockito/annotations.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';

import 'mock_stock_batches.mocks.dart';

@GenerateMocks([StockBatchRepo])
MockStockBatchRepo _builder() => MockStockBatchRepo();

final mock = _builder();

void before() {
  StockBatchRepo.instance = mock;
}

void after() {}
