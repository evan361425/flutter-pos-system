import 'package:mockito/annotations.dart';
import 'package:possystem/services/storage.dart';

import 'mock_storage.mocks.dart';

@GenerateMocks([Storage])
MockStorage _builder() => MockStorage();

late Storage _old;
final mock = _builder();

void before() {
  _old = Storage.instance;
  Storage.instance = mock;
}

void after() {
  Storage.instance = _old;
}
