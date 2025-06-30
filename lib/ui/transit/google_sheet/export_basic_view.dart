import 'package:flutter/material.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/style/snackbar_actions.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/transit/formatter/field_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/google_sheet/spreadsheet_dialog.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportBasicHeader extends StatelessWidget {
  final GoogleSheetExporter exporter;
  final ValueNotifier<FormattableModel?> selected;
  final TransitStateNotifier stateNotifier;

  const ExportBasicHeader({
    super.key,
    required this.exporter,
    required this.selected,
    required this.stateNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return SignInButton(
      signedInWidget: _ExportBasicHeader(
        exporter: exporter,
        stateNotifier: stateNotifier,
        selected: selected,
      ),
    );
  }
}

class _ExportBasicHeader extends BasicModelPicker {
  final GoogleSheetExporter exporter;

  const _ExportBasicHeader({
    required super.selected,
    required super.stateNotifier,
    required this.exporter,
    super.icon = const Icon(Icons.cloud_upload_sharp),
  });

  @override
  String get label => S.transitExportBasicBtnGoogleSheet;

  @override
  Future<void> onExport(BuildContext context, FormattableModel? able) async {
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
      allowCreateNew: true,
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
    final data = getAllFormattedFieldData(able);
    final headers = getAllFormattedFieldHeaders(able);
    Log.ger('gs_export', {'spreadsheet': ss.id, 'sheets': names});

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

class ExportBasicView extends ExportView {
  const ExportBasicView({
    super.key,
    required super.selected,
    required super.stateNotifier,
  });

  @override
  ModelData getSourceAndHeaders(FormattableModel able) {
    final formatter = findFieldFormatter(able);
    final headers = formatter.getHeader();
    return ModelData(headers, formatter.getRows());
  }
}
