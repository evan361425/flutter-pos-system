import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/replenisher.dart';

import '../../mocks/mock_storage.dart';

void main() {
  test('#constructor', () {
    when(storage.get(any)).thenAnswer((e) => Future.value({
          'id1': {
            'name': 'name1',
            'data': {'ing1': 1, 'ing2': 2},
          },
          'id2': {
            'name': 'name2',
          },
        }));
    final repo = Replenisher();

    var isCalled = false;
    repo.addListener(() {
      expect(repo.getItem('id1')!.data, equals({'ing1': 1, 'ing2': 2}));
      expect(repo.getItem('id2')!.data, equals({}));
      expect(repo.isReady, isTrue);
      isCalled = true;
    });

    Future.delayed(Duration.zero, () => expect(isCalled, isTrue));
  });

  setUpAll(() {
    initializeStorage();
  });
}
