import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';

import '../../mocks/mock_storage.dart' as storage;
import 'stock_batch_repo_test.mocks.dart';

@GenerateMocks([StockBatchModel])
void main() {
  test('#constructor', () {
    when(storage.mock.get(any)).thenAnswer((e) => Future.value({
          'id1': {
            'name': 'batch1',
            'data': {'ing1': 1, 'ing2': 2},
          },
          'id2': {
            'name': 'batch2',
          },
        }));
    final repo = StockBatchRepo();

    var isCalled = false;
    repo.addListener(() {
      expect(repo.getItem('id1')!.data, equals({'ing1': 1, 'ing2': 2}));
      expect(repo.getItem('id2')!.data, equals({}));
      expect(repo.isReady, isTrue);
      isCalled = true;
    });

    Future.delayed(Duration.zero, () => expect(isCalled, isTrue));
  });

  late StockBatchRepo repo;

  test('#hasBatch', () {
    final batch1 = MockStockBatchModel();
    final batch2 = MockStockBatchModel();
    when(batch1.name).thenReturn('a');
    when(batch2.name).thenReturn('b');
    repo.replaceItems({'a': batch1, 'b': batch2});

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
