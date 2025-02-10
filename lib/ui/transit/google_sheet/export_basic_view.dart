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

class ExportBasicView extends StatefulWidget {
  final TransitStateNotifier stateNotifier;

  final GoogleSheetExporter exporter;

  const ExportBasicView({
    super.key,
    required this.exporter,
    required this.stateNotifier,
  });

  @override
  State<ExportBasicView> createState() => _ExportBasicViewState();
}

class _ExportBasicViewState extends State<ExportBasicView> {
  final ValueNotifier<FormattableModel?> model = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: SignInButton(
          signedInWidget: Column(children: [
            ModelPicker(
              selected: model,
              onTap: _export,
              icon: Icon(Icons.cloud_upload_sharp, semanticLabel: S.transitExportBtn),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ValueListenableBuilder(valueListenable: model, builder: _buildView),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildView(BuildContext context, FormattableModel? able, Widget? child) {
    final formatter = findFieldFormatter(able ?? FormattableModel.menu);
    final headers = formatter.getHeader();
    return ModelDataTable(
      headers: headers.map((e) => e.toString()).toList(),
      notes: headers.map((e) => e.note).toList(),
      source: ModelDataTableSource(formatter.getRows()),
    );
  }

  void _export(FormattableModel? able) async {
    widget.stateNotifier.exec(() => showSnackbarWhenFutureError(
          _startExport(able),
          'excel_export_failed',
          context: context,
        ).then((link) {
          if (mounted && link != null) {
            showSnackBar(
              S.actSuccess,
              context: context,
              action: LauncherSnackbarAction(
                label: S.transitGSSpreadsheetSnackbarAction,
                link: link,
                logCode: 'gs_export',
              ),
            );
          }
        }));
  }

  /// Export data to the spreadsheet
  ///
  /// 1. Ask user to select a spreadsheet.
  /// 2. Prepare the spreadsheet, make all sheets ready.
  /// 3. Export data to the spreadsheet.
  Future<String?> _startExport(FormattableModel? able) async {
    // Step 1
    GoogleSpreadsheet? ss = await SpreadsheetDialog.show(
      context,
      exporter: widget.exporter,
      cacheKey: exportCacheKey,
      fallbackCacheKey: importCacheKey,
    );
    if (ss == null || !mounted) {
      return null;
    }

    // Step 2
    final names = able?.toL10nNames() ?? FormattableModel.allL10nNames;
    ss = await prepareSpreadsheet(
      context: context,
      exporter: widget.exporter,
      stateNotifier: widget.stateNotifier,
      defaultName: S.transitGSSpreadsheetModelDefaultName,
      cacheKey: exportCacheKey,
      sheets: names,
      spreadsheet: ss,
    );
    if (ss == null || !mounted) {
      return null;
    }

    // Step 3
    Log.ger('gs_export', {'spreadsheet': ss.id, 'sheets': ss.sheets.map((e) => e.title).toList()});
    final data = getAllFormattedFieldData(able);
    final headers = getAllFormattedFieldHeaders(able);

    await widget.exporter.updateSheet(
      ss,
      names.map((e) => ss!.sheets.firstWhere((sheet) => sheet.title == e)),
      data.map((rows) => rows.map((row) => row.map((cell) => GoogleSheetCellData.fromCellData(cell)))),
      headers.map((row) => row.map((cell) => GoogleSheetCellData.fromCellData(cell))),
    );

    Log.out('export finish', 'gs_export');
    return ss.toLink();
  }
}
