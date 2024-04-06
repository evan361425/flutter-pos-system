import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';

import '../../mocks/mock_auth.dart';
import '../../mocks/mock_google_api.dart';

void main() {
  group('Google Sheet Exporter', () {
    test('login', () async {
      when(auth.getAuthenticatedClient(scopes: anyNamed('scopes'))).thenAnswer((_) => Future.value(Client()));

      final exporter = GoogleSheetExporter();
      await exporter.auth();
      final sheetApi = await exporter.getSheetsApi(false);

      expect(sheetApi, isNotNull);
      verify(auth.getAuthenticatedClient(scopes: [])).called(1);
      verify(auth.getAuthenticatedClient(scopes: [
        gs.SheetsApi.driveFileScope,
        gs.SheetsApi.spreadsheetsScope,
      ])).called(1);
    });

    test('#addSpreadsheet', () async {
      final api = getMockSheetsApi();
      final exporter = GoogleSheetExporter(
        sheetsApi: api,
        scopes: [gs.SheetsApi.driveFileScope],
      );
      when(api.spreadsheets.create(
        argThat(predicate<gs.Spreadsheet>(
            (e) => e.properties?.title == 'title' && e.sheets?.first.properties?.title == 'sheet1')),
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet(spreadsheetId: 'abc')));

      final spreadsheet = await exporter.addSpreadsheet('title', ['sheet1']);

      expect(spreadsheet?.id, equals('abc'));
      expect(spreadsheet?.isOrigin, isTrue);
    });

    test('GoogleSheetCellData #dataValidation', () async {
      final data = GoogleSheetCellData(stringValue: 'a', options: ['b', 'c']);

      final result = data.toGoogleFormat();

      expect(
        result.dataValidation?.condition?.values?.map((e) => e.userEnteredValue).toList(),
        equals(['b', 'c']),
      );
    });

    test('GoogleSpreadsheet #fromString throw error', () {
      final value = GoogleSpreadsheet.fromString('abc');

      expect(value, isNull);
    });
  });

  setUpAll(() {
    initializeAuth();
  });
}
