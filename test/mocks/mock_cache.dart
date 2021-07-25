// database must seperate with storage, since there have same Database dependecy

import 'package:mockito/annotations.dart';
import 'package:possystem/services/cache.dart';

import 'mock_cache.mocks.dart';

final cache = MockCache();

@GenerateMocks([Cache])
void _initialize() {
  Cache.instance = cache;
  _finished = true;
}

var _finished = false;
void initializeCache() {
  if (!_finished) {
    _initialize();
  }
}
