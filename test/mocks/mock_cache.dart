// database must seperate with storage, since there have same Database dependecy

import 'package:mockito/annotations.dart';
import 'package:possystem/services/cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_cache.mocks.dart';

final service = MockSharedPreferences();

@GenerateMocks([SharedPreferences])
void _initialize() {
  Cache.instance.service = service;
  _finished = true;
}

var _finished = false;
void initializeCache() {
  if (!_finished) {
    _initialize();
  }
}
