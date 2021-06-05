import 'package:mockito/annotations.dart';
import 'package:possystem/models/repository/menu_model.dart';

import 'mock_menu.mocks.dart';

@GenerateMocks([MenuModel])
MockMenuModel _builder() => MockMenuModel();

final mock = _builder();

void before() {
  MenuModel.instance = mock;
}

void after() {}
