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

class ImportBasicView extends StatelessWidget {
  final TransitStateNotifier stateNotifier;

  final GoogleSheetExporter exporter;

  const ImportBasicView({
    super.key,
    required this.exporter,
    required this.stateNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ImportView(
      icon: const Icon(Icons.cloud_download_sharp, semanticLabel: '選擇試算表'),
      stateNotifier: stateNotifier,
      onLoad: _load,
      onDone: _done,
      allowAll: true,
    );
  }

  /// 1. Ask user to select a spreadsheet.
  /// 2. Verify all sheets are exist.
  /// 3. Import each sheet one by one.
  Future<PreviewFormatter?> _load(BuildContext context, ValueNotifier<FormattableModel?> able) async {
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
    final titles = able.value?.toL10nNames() ?? FormattableModel.allL10nNames;
    final wanted = titles.toSet();
    if (!ss.containsAll(wanted)) {
      stateNotifier.value = '準備試算表「${ss.name}」';
      final requested = await exporter.getSheets(ss);
      ss.merge(requested);
    }

    final exist = ss.sheets.map((e) => e.title).toSet();
    final missing = wanted.difference(exist);
    if (missing.isNotEmpty) {
      // ignore: use_build_context_synchronously
      showSnackBar(S.transitGSErrorImportNotFoundSheets(missing.join(', ')), context: context);
      return null;
    }

    // Step 3
    stateNotifier.value = '匯入試算表...';
    Log.ger('gs_import', {'spreadsheet': ss.id, 'sheets': titles});

    final ables = able.value?.toList() ?? FormattableModel.values;
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

  void _done(BuildContext context) {
    showSnackBar(S.actSuccess, context: context);
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
