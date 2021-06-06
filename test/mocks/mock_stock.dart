import 'package:mockito/annotations.dart';
import 'package:possystem/models/repository/stock_model.dart';

import 'mock_stock.mocks.dart';

@GenerateMocks([StockModel])
MockStockModel _builder() => MockStockModel();

final mock = _builder();

void before() {
  StockModel.instance = mock;
}

void after() {}
