import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/transit/formatter/field_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/google_sheet/spreadsheet_dialog.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ImportBasicHeader extends ImportBasicBaseHeader {
  final GoogleSheetExporter exporter;

  const ImportBasicHeader({
    super.key,
    required super.selected,
    required super.stateNotifier,
    required super.formatter,
    required this.exporter,
    super.icon = const Icon(Icons.cloud_download_sharp),
    super.allowAll = true,
  });

  @override
  String get label => S.transitImportBtnGoogleSheet;
  @override
  String get errorMessage => S.transitImportErrorGoogleSheetFetchDataTitle;
  @override
  String get moreMessage => S.transitImportErrorGoogleSheetFetchDataHelper;

  /// 1. Ask user to select a spreadsheet.
  /// 2. Verify all sheets are exist.
  /// 3. Import each sheet one by one.
  @override
  Future<PreviewFormatter?> onImport(BuildContext context) async {
    // Step 1
    GoogleSpreadsheet? ss = await SpreadsheetDialog.show(
      context,
      exporter: exporter,
      cacheKey: importCacheKey,
      fallbackCacheKey: exportCacheKey,
    );
    if (ss == null || !context.mounted) {
      return null;
    }

    // Step 2
    final titles = selected.value?.toL10nNames() ?? FormattableModel.allL10nNames;
    if (await showSnackbarWhenFutureError(
          _prepareSheets(ss, titles),
          'import_sheet_preparing',
          context: context,
          showIfFalse: true,
          message: S.transitImportErrorGoogleSheetMissingTitle(titles.join(', ')),
          more: S.transitImportErrorGoogleSheetMissingHelper,
        ) !=
        true) {
      return null;
    }

    // Step 3
    stateNotifier.value = S.transitImportProgressGoogleSheetStart;
    Log.ger('gs_import', {'spreadsheet': ss.id, 'sheets': titles});

    final ables = selected.value?.toList() ?? FormattableModel.values;
    final sheets = titles.map((title) => ss.sheets.firstWhere((e) => e.title == title)).toList();
    final data = await _requestData(ss, ables, sheets);

    return (FormattableModel able) {
      final rows = data[able];
      if (rows == null) {
        return null;
      }

      return findFieldFormatter(able).format(rows);
    };
  }

  Future<bool> _prepareSheets(GoogleSpreadsheet ss, List<String> titles) async {
    final wanted = titles.toSet();
    if (!ss.containsAll(wanted)) {
      stateNotifier.value = S.transitImportProgressGoogleSheetPrepare;
      final requested = await exporter.getSheets(ss);
      ss.merge(requested);
    }

    final exist = ss.sheets.map((e) => e.title).toSet();
    final missing = wanted.difference(exist);
    return missing.isEmpty;
  }

  /// Request the data from the sheet.
  Future<Map<FormattableModel, List<List<Object?>>?>> _requestData(
    GoogleSpreadsheet ss,
    List<FormattableModel> ables,
    List<GoogleSheetProperties> sheets,
  ) async {
    final futures = sheets
        .mapIndexed((i, sheet) => exporter.getSheetData(
              ss,
              sheet.title,
              neededColumns: findFieldFormatter(ables[i]).getHeader().length,
            ))
        .toList();

    final data = await Future.wait(futures);
    return {
      for (final (i, rows) in data.indexed) ables[i]: rows?.sublist(1),
    };
  }
}
