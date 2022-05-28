import 'package:googleapis/drive/v3.dart' as gd;
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:mockito/annotations.dart';

import 'mock_google_api.mocks.dart';

@GenerateMocks([gd.DriveApi, gd.FilesResource])
CustomMockDriveApi getMockDriveApi() {
  return CustomMockDriveApi();
}

@GenerateMocks([
  gs.SheetsApi,
  gs.SpreadsheetsResource,
  gs.SpreadsheetsValuesResource,
])
CustomMockSheetsApi getMockSheetsApi() {
  return CustomMockSheetsApi();
}

class CustomMockDriveApi extends MockDriveApi {
  final MockFilesResource mockFiles = MockFilesResource();

  @override
  MockFilesResource get files => mockFiles;
}

class CustomMockSheetsApi extends MockSheetsApi {
  final mockSpreadsheets = CustomMockSpreadsheetsResource();

  @override
  CustomMockSpreadsheetsResource get spreadsheets => mockSpreadsheets;
}

class CustomMockSpreadsheetsResource extends MockSpreadsheetsResource {
  final mockSpreadsheetsValues = MockSpreadsheetsValuesResource();

  @override
  MockSpreadsheetsValuesResource get values => mockSpreadsheetsValues;
}
