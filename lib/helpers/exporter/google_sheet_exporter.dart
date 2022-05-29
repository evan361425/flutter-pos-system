import 'package:file_picker/file_picker.dart';
import 'package:googleapis/content/v2_1.dart';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/services/auth.dart';

class GoogleSheetExporter {
  GoogleSheetExporter({gs.SheetsApi? sheetsApi, gd.DriveApi? driveApi})
      : _driveApi = driveApi,
        _sheetsApi = sheetsApi;

  gs.SheetsApi? _sheetsApi;

  gd.DriveApi? _driveApi;

  Future<gd.DriveApi?> getDriveApi() {
    return _setApiClient().then((_) => _driveApi);
  }

  Future<gs.SheetsApi?> getSheetsApi() {
    return _setApiClient().then((_) => _sheetsApi);
  }

  gs.SheetProperties getNewSheetProperties(String title) => gs.SheetProperties(
        title: title,
        // indigo
        tabColor: gs.Color(red: 0.24706, green: 0.31765, blue: 0.70980),
      );

  Future<GoogleSpreadsheet?> addSpreadsheet(
    String title,
    List<String> sheetTitles,
  ) async {
    final sheetsApi = await getSheetsApi();
    info(title, 'google_sheet_exporter.add_spreadsheet');
    final result = await sheetsApi?.spreadsheets.create(
      gs.Spreadsheet(
        properties: gs.SpreadsheetProperties(title: title),
        sheets: [
          for (final sheetTitle in sheetTitles)
            gs.Sheet(properties: getNewSheetProperties(sheetTitle))
        ],
      ),
      $fields: 'spreadsheetId,sheets(properties(sheetId,title))',
    );

    if (result?.spreadsheetId == null) {
      return null;
    }

    info(result!.spreadsheetId!, 'google_sheet_exporter.add_spreadsheet_s');
    return GoogleSpreadsheet(
      id: result.spreadsheetId!,
      name: title,
      sheets: GoogleSheetProperties.fromSheet(result.sheets),
    );
  }

  Future<List<GoogleSheetProperties>?> addSheets(
    String spreadsheetId,
    List<String> titles,
  ) async {
    final requests = [
      for (final title in titles)
        gs.Request(
          addSheet: gs.AddSheetRequest(
            properties: getNewSheetProperties(title),
          ),
        ),
    ];

    final sheetApi = await getSheetsApi();
    info(titles.length.toString(), 'google_sheet_exporter.add_sheets');
    final result = await sheetApi?.spreadsheets.batchUpdate(
      gs.BatchUpdateSpreadsheetRequest(requests: requests),
      spreadsheetId,
    );

    final replies = result?.replies;
    if (replies == null ||
        replies.any((reply) => reply.addSheet?.properties?.sheetId == null)) {
      return null;
    }

    info('', 'google_sheet_exporter.add_sheets_s');
    return replies
        .map((reply) => GoogleSheetProperties(
            reply.addSheet!.properties!.sheetId!,
            reply.addSheet!.properties!.title!))
        .toList();
  }

  Future<List<GoogleSheetProperties>> getSheets(String spreadsheetId) async {
    final sheetsApi = await getSheetsApi();
    final res = await sheetsApi?.spreadsheets.get(
      spreadsheetId,
      $fields: 'sheets(properties(sheetId,title))',
    );

    return GoogleSheetProperties.fromSheet(res?.sheets);
  }

  Future<String?> findSpreadsheetIdByName(String name) async {
    final driveApi = await getDriveApi();
    debug(name, 'google_sheet_exporter.find_sheet');
    final drive = await driveApi?.files.list(
      q: [
        "mimeType = 'application/vnd.google-apps.spreadsheet'",
        "name = '$name'",
        "trashed = false",
      ].join(' and '),
      $fields: 'files(id)',
    );

    if (drive?.files?.isEmpty != false) {
      info(name, 'google_sheet_exporter.find_missed');
      return null;
    }

    return drive!.files!.first.id;
  }

  Future<GoogleSpreadsheet?> pickSheet() async {
    final picked = await FilePicker.platform.pickFiles();
    if (picked == null || picked.files.isEmpty) {
      return null;
    }

    final pickedName = Util.removeExtension(picked.files.first.name);
    info(pickedName, 'google_sheet_exporter.pick_name');
    final id = await findSpreadsheetIdByName(pickedName);
    if (id == null) {
      throw GoogleSheetError('non_exist_name');
    }

    debug(id, 'google_sheet_exporter.pick_sheet');
    final sheets = await getSheets(id);
    return GoogleSpreadsheet(
      id: id,
      name: pickedName,
      sheets: sheets,
    );
  }

  /// 更新表單
  ///
  /// [hiddenColumnIndex] 1-index
  Future<void> updateSheet(
    String spreadsheetId,
    int sheetId,
    List<List<GoogleSheetCellData>> data,
    List<GoogleSheetCellData> header,
  ) async {
    final requests = [
      gs.Request(
        updateCells: gs.UpdateCellsRequest(
          rows: [
            gs.RowData(values: [
              for (final cell in header) cell.toGoogleFormat(),
            ]),
            for (final row in data)
              gs.RowData(values: [
                for (final cell in row) cell.toGoogleFormat(),
              ])
          ],
          fields: 'userEnteredValue,userEnteredFormat,dataValidation,note',
          start: gs.GridCoordinate(
            rowIndex: 0,
            columnIndex: 0,
            sheetId: sheetId,
          ),
        ),
      ),
    ];

    final sheetsApi = await getSheetsApi();
    await sheetsApi?.spreadsheets.batchUpdate(
      gs.BatchUpdateSpreadsheetRequest(requests: requests),
      spreadsheetId,
      $fields: 'spreadsheetId',
    );
  }

  Future<List<List<Object?>>?> getSheetData(
    String spreadsheetId,
    String sheetTitle, {
    required int neededColumns,
  }) async {
    final sheetsApi = await getSheetsApi();
    final result = await sheetsApi?.spreadsheets.values.get(
      spreadsheetId,
      // TODO: if neededColumns are better than 26, this must change
      "'$sheetTitle'!A:${String.fromCharCode(64 + neededColumns)}",
      majorDimension: 'ROWS',
      $fields: 'values',
    );

    return result?.values?.map((row) {
      row.addAll(List<String>.filled(neededColumns - row.length, ''));
      return row;
    }).toList();
  }

  Future<void> auth() => _setApiClient();

  Future<void> _setApiClient() async {
    // allow mock only one object
    if (_sheetsApi != null || _driveApi != null) {
      return;
    }

    if (await Auth.instance.loginIfNot()) {
      final client = await Auth.instance.getAuthenticatedClient(
        scopes: [
          gs.SheetsApi.spreadsheetsScope,
          gd.DriveApi.driveMetadataReadonlyScope,
        ],
      );

      if (client != null) {
        _sheetsApi = gs.SheetsApi(client);
        _driveApi = gd.DriveApi(client);
      }
    }
  }
}

class GoogleSpreadsheet {
  final String id;

  final String name;

  final List<GoogleSheetProperties> sheets;

  GoogleSpreadsheet({
    required this.id,
    required this.name,
    required this.sheets,
  });

  @override
  String toString() {
    return id;
  }
}

class GoogleSheetProperties {
  final int id;

  final String title;

  GoogleSheetProperties(this.id, this.title);

  static List<GoogleSheetProperties> fromSheet(List<gs.Sheet>? sheets) {
    return sheets
            ?.where((sheet) =>
                sheet.properties != null &&
                sheet.properties!.sheetId != null &&
                sheet.properties!.title != null)
            .map((sheet) => GoogleSheetProperties(
                  sheet.properties!.sheetId!,
                  sheet.properties!.title!,
                ))
            .toList() ??
        <GoogleSheetProperties>[];
  }

  static GoogleSheetProperties? fromCacheValue(String? value) {
    if (value == null) return null;

    final index = value.lastIndexOf(' ');
    if (index == -1) return null;

    final name = value.substring(0, index);
    final id = int.tryParse(value.substring(index + 1));
    if (name.isEmpty || id == null) return null;

    return GoogleSheetProperties(id, name);
  }

  String toCacheValue() => '$title $id';

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is GoogleSheetProperties &&
        other.id == id &&
        other.title == title;
  }
}

class GoogleSheetCellData {
  final gs.ExtendedValue value;

  final gs.CellFormat format;

  final String? note;

  final List<String>? options;

  GoogleSheetCellData({
    String? formulaValue,
    num? numberValue,
    String? stringValue,
    bool isBold = false,
    this.note,
    this.options,
  })  : value = gs.ExtendedValue(
          formulaValue: formulaValue,
          numberValue: numberValue?.toDouble(),
          stringValue: stringValue,
        ),
        format = gs.CellFormat(
          textFormat: isBold ? gs.TextFormat(bold: true) : null,
        );

  gs.CellData toGoogleFormat() {
    return gs.CellData(
      userEnteredValue: value,
      userEnteredFormat: format,
      dataValidation: options == null
          ? null
          : gs.DataValidationRule(
              condition: gs.BooleanCondition(
                type: 'ONE_OF_LIST',
                values: options!
                    .map((e) => gs.ConditionValue(userEnteredValue: e))
                    .toList(),
              ),
            ),
      note: note,
    );
  }

  @override
  String toString() {
    return value.stringValue ?? value.numberValue!.toString();
  }
}

class GoogleSheetError extends Error {
  final String code;

  GoogleSheetError(this.code);
}
