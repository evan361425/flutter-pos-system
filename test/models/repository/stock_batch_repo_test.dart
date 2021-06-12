import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';

import '../../mocks/mock_storage.dart' as storage;
import 'stock_batch_repo_test.mocks.dart';

@GenerateMocks([StockBatchModel])
void main() {
  late StockBatchRepo repo;
  test('#hasBatch', () {
    final batch1 = MockStockBatchModel();
    final batch2 = MockStockBatchModel();
    when(batch1.name).thenReturn('a');
    when(batch2.name).thenReturn('b');
    repo.replaceChilds({'a': batch1, 'b': batch2});

    expect(repo.hasBatch('a'), isTrue);
    expect(repo.hasBatch('c'), isFalse);
  });

  setUp(() {
    when(storage.mock.get(any)).thenAnswer((e) => Future.value({}));
    repo = StockBatchRepo();
  });

  setUpAll(() {
    storage.before();
  });

  tearDownAll(() {
    storage.after();
  });
}
