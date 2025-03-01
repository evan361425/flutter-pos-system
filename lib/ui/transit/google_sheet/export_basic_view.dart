import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/style/snackbar_actions.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/transit/formatter/field_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/google_sheet/spreadsheet_dialog.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportBasicView extends StatelessWidget {
  final TransitStateNotifier stateNotifier;

  final GoogleSheetExporter exporter;

  const ExportBasicView({
    super.key,
    required this.exporter,
    required this.stateNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ExportView(
      icon: Icon(Icons.cloud_upload_sharp, semanticLabel: S.transitExportBasicBtnGoogleSheet),
      stateNotifier: stateNotifier,
      allowAll: true,
      onExport: _export,
      buildModel: _buildModel,
    );
  }

  Widget _buildModel(BuildContext context, FormattableModel? able) {
    final formatter = findFieldFormatter(able ?? FormattableModel.menu);
    final headers = formatter.getHeader();
    return ModelDataTable(
      headers: headers.map((e) => e.toString()).toList(),
      notes: headers.map((e) => e.note).toList(),
      source: ModelDataTableSource(formatter.getRows()),
    );
  }

  Future<void> _export(BuildContext context, FormattableModel? able) async {
    final link = await _startExport(context, able);

    if (context.mounted && link != null) {
      showSnackBar(
        S.transitExportBasicSuccessGoogleSheet,
        context: context,
        action: LauncherSnackbarAction(
          label: S.transitExportBasicSuccessActionGoogleSheet,
          link: link,
          logCode: 'gs_export',
        ),
      );
    }
  }

  /// Export data to the spreadsheet
  ///
  /// 1. Ask user to select a spreadsheet.
  /// 2. Prepare the spreadsheet, make all sheets ready.
  /// 3. Export data to the spreadsheet.
  Future<String?> _startExport(BuildContext context, FormattableModel? able) async {
    // Step 1
    GoogleSpreadsheet? ss = await SpreadsheetDialog.show(
      context,
      exporter: exporter,
      cacheKey: exportCacheKey,
      fallbackCacheKey: importCacheKey,
    );
    if (ss == null || !context.mounted) {
      return null;
    }

    // Step 2
    final names = able?.toL10nNames() ?? FormattableModel.allL10nNames;
    ss = await prepareSpreadsheet(
      context: context,
      exporter: exporter,
      stateNotifier: stateNotifier,
      defaultName: S.transitExportBasicFileName,
      cacheKey: exportCacheKey,
      sheets: names,
      spreadsheet: ss,
    );
    if (ss == null || !context.mounted) {
      return null;
    }

    // Step 3
    Log.ger('gs_export', {'spreadsheet': ss.id, 'sheets': names});
    final data = getAllFormattedFieldData(able);
    final headers = getAllFormattedFieldHeaders(able);

    await exporter.updateSheet(
      ss,
      names.map((e) => ss!.sheets.firstWhere((sheet) => sheet.title == e)),
      data.map((rows) => rows.map((row) => row.map((cell) => GoogleSheetCellData.fromCellData(cell)))),
      headers.map((row) => row.map((cell) => GoogleSheetCellData.fromCellData(cell))),
    );

    Log.out('export finish', 'gs_export');
    return ss.toLink();
  }
}
