// database must seperate with storage, since there have same Database dependecy

import 'package:mockito/annotations.dart';
import 'package:possystem/services/database.dart';

import 'mock_database.mocks.dart';

final database = MockDatabase();

@GenerateMocks([Database])
void _initialize() {
  Database.instance = database;
  _finished = true;
}

var _finished = false;
void initializeDatabase() {
  if (!_finished) {
    _initialize();
  }
}
