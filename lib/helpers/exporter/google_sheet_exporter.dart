import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/auth.dart';

class GoogleSheetExporter {
  GoogleSheetExporter({
    gs.SheetsApi? sheetsApi,
    List<String> scopes = const [],
  })  : _sheetsApi = sheetsApi,
        _scopes = scopes;

  gs.SheetsApi? _sheetsApi;

  List<String> _scopes;

  Future<gs.SheetsApi?> getSheetsApi(bool isOrigin) {
    final scopes = isOrigin
        ? const [gs.SheetsApi.driveFileScope]
        : const [gs.SheetsApi.driveFileScope, gs.SheetsApi.spreadsheetsScope];
    return _setApiClient(scopes).then((_) => _sheetsApi);
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
    final sheetsApi = await getSheetsApi(true);
    Log.ger('start', 'exporter_gs_add_spreadsheet');
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
      Log.ger('miss', 'exporter_gs_add_spreadsheet');
      return null;
    }

    Log.ger('success', 'exporter_gs_add_spreadsheet');
    return GoogleSpreadsheet(
      id: result!.spreadsheetId!,
      name: title,
      sheets: GoogleSheetProperties.fromSheet(result.sheets),
      isOrigin: true,
    );
  }

  Future<GoogleSpreadsheet?> getSpreadsheet(String id) async {
    final sheetsApi = await getSheetsApi(false);
    Log.ger('start', 'exporter_gs_get_spreadsheet');
    final res = await sheetsApi?.spreadsheets.get(
      id,
      includeGridData: false,
      $fields: 'properties.title,sheets.properties(sheetId,title)',
    );

    if (res?.properties?.title == null) {
      Log.ger('miss', 'exporter_gs_get_spreadsheet');
      return null;
    }

    Log.ger('done', 'exporter_gs_get_spreadsheet');
    return GoogleSpreadsheet(
      id: id,
      name: res!.properties!.title!,
      sheets: GoogleSheetProperties.fromSheet(res.sheets),
      isOrigin: false,
    );
  }

  Future<List<GoogleSheetProperties>?> addSheets(
    GoogleSpreadsheet spreadsheet,
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

    final sheetApi = await getSheetsApi(spreadsheet.isOrigin);
    Log.ger('start ${titles.length}', 'exporter_gs_add_sheets');
    final result = await sheetApi?.spreadsheets.batchUpdate(
      gs.BatchUpdateSpreadsheetRequest(requests: requests),
      spreadsheet.id,
    );

    final replies = result?.replies;
    if (replies == null ||
        replies.any((reply) => reply.addSheet?.properties?.sheetId == null)) {
      Log.ger('miss', 'exporter_gs_add_sheets');
      return null;
    }

    Log.ger('success', 'exporter_gs_add_sheets');
    return replies
        .map((reply) => GoogleSheetProperties(
            reply.addSheet!.properties!.sheetId!,
            reply.addSheet!.properties!.title!))
        .toList();
  }

  Future<List<GoogleSheetProperties>> getSheets(
    GoogleSpreadsheet spreadsheet,
  ) async {
    final sheetsApi = await getSheetsApi(spreadsheet.isOrigin);
    Log.ger('start', 'exporter_gs_get_sheets');
    final res = await sheetsApi?.spreadsheets.get(
      spreadsheet.id,
      includeGridData: false,
      $fields: 'sheets(properties(sheetId,title))',
    );

    Log.ger('done', 'exporter_gs_get_sheets');
    return GoogleSheetProperties.fromSheet(res?.sheets);
  }

  /// 更新表單
  ///
  /// [hiddenColumnIndex] 1-index
  Future<void> updateSheet(
    GoogleSpreadsheet spreadsheet,
    GoogleSheetProperties sheet,
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
            sheetId: sheet.id,
          ),
        ),
      ),
    ];

    final sheetsApi = await getSheetsApi(spreadsheet.isOrigin);
    Log.ger(sheet.typeName, 'exporter_gs_update_sheet');
    await sheetsApi?.spreadsheets.batchUpdate(
      gs.BatchUpdateSpreadsheetRequest(requests: requests),
      spreadsheet.id,
      $fields: 'spreadsheetId',
    );
  }

  Future<List<List<Object?>>?> getSheetData(
    GoogleSpreadsheet spreadsheet,
    String sheetTitle, {
    required int neededColumns,
  }) async {
    final sheetsApi = await getSheetsApi(spreadsheet.isOrigin);
    Log.ger('start', 'exporter_gs_get_data');
    final result = await sheetsApi?.spreadsheets.values.get(
      spreadsheet.id,
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

  Future<void> _setApiClient([List<String> scopes = const []]) async {
    final exist = _scopes.toSet();
    final wanted = scopes.toSet();
    if (_sheetsApi != null && wanted.difference(exist).isEmpty) {
      return;
    }

    if (await Auth.instance.loginIfNot()) {
      final client = await Auth.instance.getAuthenticatedClient(scopes: scopes);

      if (client != null) {
        _sheetsApi = gs.SheetsApi(client);
        _scopes = exist.union(wanted).toList();
      }
    }
  }
}

class GoogleSpreadsheet {
  final String id;

  final String name;

  final List<GoogleSheetProperties> sheets;

  // If this spreadsheet created by pos-system
  final bool isOrigin;

  GoogleSpreadsheet({
    required this.id,
    required this.name,
    required this.sheets,
    this.isOrigin = false,
  });

  static GoogleSpreadsheet? fromString(String value) {
    try {
      var index = value.indexOf(':');
      final id = value.substring(0, index);
      value = value.substring(index + 1);
      index = value.indexOf(':');
      final isOrigin = value.substring(0, index) == 'true';
      final name = value.substring(index + 1);

      return GoogleSpreadsheet(
        id: id,
        name: name,
        sheets: [],
        isOrigin: isOrigin,
      );
    } catch (error, stack) {
      Log.err(error, 'gs_spreadsheet_format_failed', stack);
      return null;
    }
  }

  @override
  String toString() {
    return '$id:$isOrigin:$name';
  }
}

class GoogleSheetProperties {
  final int id;

  final String title;

  final String typeName;

  GoogleSheetProperties(this.id, this.title, {this.typeName = ''});

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
