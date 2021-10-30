// database must seperate with storage, since there have same Database dependecy

import 'package:mockito/annotations.dart';
import 'package:possystem/services/cache.dart';

import 'mock_cache.mocks.dart';

final cache = MockCache();

@GenerateMocks([Cache])
void initializeCache() {
  Cache.instance = cache;
}
