import 'package:collection/collection.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/auth.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';

import 'data_exporter.dart';

class GoogleSheetExporter extends DataExporter {
  GoogleSheetExporter({
    this.sheetsApi,
    this.scopes = const [],
  });

  gs.SheetsApi? sheetsApi;

  List<String> scopes;

  Future<gs.SheetsApi?> getSheetsApi(bool isOrigin) {
    // TODO: should use gRPC
    final scopes = isOrigin
        ? const [gs.SheetsApi.driveFileScope]
        : const [gs.SheetsApi.driveFileScope, gs.SheetsApi.spreadsheetsScope];
    return _setApiClient(scopes).then((_) => sheetsApi);
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
    Log.out('add_spreadsheet start', _logCode);
    final result = await sheetsApi?.spreadsheets.create(
      gs.Spreadsheet(
        properties: gs.SpreadsheetProperties(title: title),
        sheets: [for (final sheetTitle in sheetTitles) gs.Sheet(properties: getNewSheetProperties(sheetTitle))],
      ),
      $fields: 'spreadsheetId,sheets(properties(sheetId,title))',
    );

    if (result?.spreadsheetId == null) {
      Log.out('add_spreadsheet miss', _logCode);
      return null;
    }

    Log.out('add_spreadsheet success', _logCode);
    return GoogleSpreadsheet(
      id: result!.spreadsheetId!,
      name: title,
      sheets: GoogleSheetProperties.fromSheet(result.sheets),
      isOrigin: true,
    );
  }

  /// Find the spreadsheet by the given id.
  Future<GoogleSpreadsheet?> getSpreadsheet(String id) async {
    final sheetsApi = await getSheetsApi(false);
    Log.out('get_spreadsheet start', _logCode);
    final res = await sheetsApi?.spreadsheets.get(
      id,
      includeGridData: false,
      $fields: 'properties.title,sheets.properties(sheetId,title)',
    );

    if (res?.properties?.title == null) {
      Log.out('get_spreadsheet miss', _logCode);
      return null;
    }

    Log.out('get_spreadsheet done', _logCode);
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
    Log.out('add_sheets start ${titles.length}', _logCode);
    final result = await sheetApi?.spreadsheets.batchUpdate(
      gs.BatchUpdateSpreadsheetRequest(requests: requests),
      spreadsheet.id,
    );

    final replies = result?.replies;
    if (replies == null || replies.any((reply) => reply.addSheet?.properties?.sheetId == null)) {
      Log.out('add_sheets miss', _logCode);
      return null;
    }

    Log.out('add_sheets success', _logCode);
    return replies
        .map((reply) => GoogleSheetProperties(reply.addSheet!.properties!.sheetId!, reply.addSheet!.properties!.title!))
        .toList();
  }

  Future<List<GoogleSheetProperties>> getSheets(
    GoogleSpreadsheet spreadsheet,
  ) async {
    final sheetsApi = await getSheetsApi(spreadsheet.isOrigin);
    Log.out('get_sheets start', _logCode);
    final res = await sheetsApi?.spreadsheets.get(
      spreadsheet.id,
      includeGridData: false,
      $fields: 'sheets(properties(sheetId,title))',
    );

    Log.out('get_sheets done', _logCode);
    return GoogleSheetProperties.fromSheet(res?.sheets);
  }

  /// Update the sheet with the given data.
  Future<void> updateSheet(
    GoogleSpreadsheet spreadsheet,
    Iterable<GoogleSheetProperties> sheets,
    Iterable<Iterable<Iterable<GoogleSheetCellData>>> data,
    Iterable<Iterable<GoogleSheetCellData>> headers,
  ) async {
    final hi = headers.iterator;
    final di = data.iterator;
    final requests = sheets.map((sheet) {
      hi.moveNext();
      di.moveNext();
      return gs.Request(
        updateCells: gs.UpdateCellsRequest(
          rows: [
            gs.RowData(values: [
              for (final cell in hi.current) cell.toGoogleFormat(),
            ]),
            for (final row in di.current)
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
      );
    }).toList();

    final sheetsApi = await getSheetsApi(spreadsheet.isOrigin);
    final types = sheets.map((e) => e.typeName).join(' ');
    Log.out('update_sheet $types', _logCode);
    await sheetsApi?.spreadsheets.batchUpdate(
      gs.BatchUpdateSpreadsheetRequest(requests: requests),
      spreadsheet.id,
      $fields: 'spreadsheetId',
    );
  }

  /// Update the sheet with the given data in batch.
  Future<void> updateSheetValues(
    GoogleSpreadsheet spreadsheet,
    Iterable<GoogleSheetProperties> sheets,
    Iterable<Iterable<List<Object>>> data,
    Iterable<Iterable<Object>> headers,
  ) async {
    final hi = headers.iterator;
    final di = data.iterator;
    final values = sheets.map((sheet) {
      hi.moveNext();
      di.moveNext();
      return gs.ValueRange(
        majorDimension: 'ROWS',
        range: sheet.title,
        values: [hi.current.toList(), ...di.current],
      );
    });

    final sheetsApi = await getSheetsApi(spreadsheet.isOrigin);
    final types = sheets.map((e) => e.typeName).join(' ');
    Log.out('append_values $types', _logCode);
    await sheetsApi?.spreadsheets.values.batchUpdate(
      gs.BatchUpdateValuesRequest(
        includeValuesInResponse: false,
        valueInputOption: "USER_ENTERED",
        data: values.toList(),
      ),
      spreadsheet.id,
      $fields: 'spreadsheetId',
    );
  }

  /// Update the sheet by appending the given data.
  Future<void> appendSheetValues(
    GoogleSpreadsheet spreadsheet,
    GoogleSheetProperties sheet,
    Iterable<List<Object>> data,
  ) async {
    final sheetsApi = await getSheetsApi(spreadsheet.isOrigin);
    Log.out('append_values ${sheet.typeName}', _logCode);
    await sheetsApi?.spreadsheets.values.append(
      gs.ValueRange(
        majorDimension: 'ROWS',
        range: "'${sheet.title}'",
        values: data.toList(),
      ),
      spreadsheet.id,
      "'${sheet.title}'",
      includeValuesInResponse: false,
      insertDataOption: 'INSERT_ROWS',
      valueInputOption: "USER_ENTERED",
      $fields: 'spreadsheetId',
    );
  }

  Future<List<List<Object?>>?> getSheetData(
    GoogleSpreadsheet spreadsheet,
    String sheetTitle, {
    required int neededColumns,
  }) async {
    final sheetsApi = await getSheetsApi(spreadsheet.isOrigin);
    Log.out('get_data start', _logCode);
    final result = await sheetsApi?.spreadsheets.values.get(
      spreadsheet.id,
      // TODO: if neededColumns are greater than 26, this must change
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
    final exist = this.scopes.toSet();
    final wanted = scopes.toSet();
    if (sheetsApi != null && wanted.difference(exist).isEmpty) {
      return;
    }

    final client = await Auth.instance.getAuthenticatedClient(scopes: scopes);

    if (client != null) {
      sheetsApi = gs.SheetsApi(client);
      this.scopes = exist.union(wanted).toList();
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
      Log.err(error, '${_logCode}_format_failed', stack);
      return null;
    }
  }

  String toLink() {
    return 'https://docs.google.com/spreadsheets/d/$id/edit';
  }

  /// Merge the given sheets into the current sheets which is compared by id.
  void merge(List<GoogleSheetProperties> others) {
    final diff = others.where((sheet) => sheets.firstWhereOrNull((e) => e.id == sheet.id) == null);

    sheets.addAll(diff);
  }

  /// Check if the given sheets' title all in the current sheets.
  bool containsAll(Set<String> sheets) {
    return this.sheets.map((e) => e.title).toSet().containsAll(sheets);
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
                sheet.properties != null && sheet.properties!.sheetId != null && sheet.properties!.title != null)
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
  bool operator ==(Object other) {
    return other is GoogleSheetProperties && other.id == id && other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}

class GoogleSheetCellData extends CellData {
  final gs.ExtendedValue gsValue;

  final gs.CellFormat? format;

  GoogleSheetCellData({
    super.string,
    super.number,
    super.isBold,
    super.note,
    super.options,
  })  : gsValue = gs.ExtendedValue(
          numberValue: number?.toDouble(),
          stringValue: string,
        ),
        format = isBold == true ? gs.CellFormat(textFormat: gs.TextFormat(bold: true)) : null;

  factory GoogleSheetCellData.fromCellData(CellData cell) {
    return GoogleSheetCellData(
      string: cell.string,
      number: cell.number,
      isBold: cell.isBold,
      note: cell.note,
      options: cell.options,
    );
  }

  gs.CellData toGoogleFormat() {
    return gs.CellData(
      userEnteredValue: gsValue,
      userEnteredFormat: format,
      dataValidation: options == null
          ? null
          : gs.DataValidationRule(
              condition: gs.BooleanCondition(
                type: 'ONE_OF_LIST',
                values: options!.map((e) => gs.ConditionValue(userEnteredValue: e)).toList(),
              ),
            ),
      note: note,
    );
  }
}

const _logCode = 'exporter_gs';
