import 'package:mockito/annotations.dart';
import 'package:possystem/models/repository/quantity_repo.dart';

import 'mock_quantities.mocks.dart';

@GenerateMocks([QuantityRepo])
MockQuantityRepo _builder() => MockQuantityRepo();

final mock = _builder();

void before() {
  QuantityRepo.instance = mock;
}

void after() {}
