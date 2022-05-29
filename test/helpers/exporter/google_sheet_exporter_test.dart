import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v2.dart' as gd;
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';

import '../../mocks/mock_auth.dart';
import '../../mocks/mock_google_api.dart';

void main() {
  group('Google Sheet Exporter', () {
    test('login', () async {
      when(auth.loginIfNot()).thenAnswer((_) => Future.value(true));
      when(auth.getAuthenticatedClient(scopes: anyNamed('scopes')))
          .thenAnswer((_) => Future.value(Client()));

      final exporter = GoogleSheetExporter();
      final sheetApi = await exporter.getSheetsApi();
      final driveApi = await exporter.getDriveApi();

      expect(sheetApi, isNotNull);
      expect(driveApi, isNotNull);
      verify(auth.getAuthenticatedClient(scopes: [
        gs.SheetsApi.spreadsheetsScope,
        gd.DriveApi.driveMetadataReadonlyScope,
      ])).called(1);
    });

    test('#addSpreadsheet', () async {
      final api = getMockSheetsApi();
      final exporter = GoogleSheetExporter(sheetsApi: api);
      when(api.spreadsheets.create(
        argThat(predicate<gs.Spreadsheet>((e) =>
            e.properties?.title == 'title' &&
            e.sheets?.first.properties?.title == 'sheet1')),
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet(spreadsheetId: 'abc')));

      final spreadsheet = await exporter.addSpreadsheet('title', ['sheet1']);

      expect(spreadsheet?.id, equals('abc'));
    });

    test('GoogleSheetCellData #dataValidation', () async {
      final data = GoogleSheetCellData(stringValue: 'a', options: ['b', 'c']);

      final result = data.toGoogleFormat();

      expect(
        result.dataValidation?.condition?.values
            ?.map((e) => e.userEnteredValue)
            .toList(),
        equals(['b', 'c']),
      );
    });
  });

  setUpAll(() {
    initializeAuth();
  });
}
