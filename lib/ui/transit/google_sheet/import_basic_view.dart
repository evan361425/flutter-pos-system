import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/formatter/google_sheet_formatter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';

import 'sheet_preview_page.dart';
import 'sheet_selector.dart';
import 'spreadsheet_selector.dart';

const _cacheKey = 'importer_google_sheet';

class ImportBasicView extends StatefulWidget {
  final ValueNotifier<String> notifier;

  final GoogleSheetExporter exporter;

  const ImportBasicView({
    super.key,
    required this.exporter,
    required this.notifier,
  });

  @override
  State<ImportBasicView> createState() => _ImportBasicViewState();
}

class _ImportBasicViewState extends State<ImportBasicView> {
  final sheets = <Formattable, GlobalKey<SheetSelectorState>>{
    Formattable.menu: GlobalKey<SheetSelectorState>(),
    Formattable.stock: GlobalKey<SheetSelectorState>(),
    Formattable.quantities: GlobalKey<SheetSelectorState>(),
    Formattable.replenisher: GlobalKey<SheetSelectorState>(),
    Formattable.orderAttr: GlobalKey<SheetSelectorState>(),
  };

  final selector = GlobalKey<SpreadsheetSelectorState>();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SignInButton(
            signedInWidget: SpreadsheetSelector(
              key: selector,
              exporter: widget.exporter,
              notifier: widget.notifier,
              cacheKey: _cacheKey,
              existLabel: S.transitGSSpreadsheetImportExistLabel,
              existHint: (_) => S.transitGSSpreadsheetImportExistHint,
              emptyLabel: S.transitGSSpreadsheetImportEmptyLabel,
              emptyHint: S.transitGSSpreadsheetImportEmptyHint,
              onUpdated: reloadSheetHints,
              onChosen: reloadSheets,
            ),
          ),
        ),
        ListTile(
          key: const Key('gs_export.import_all'),
          title: Text(S.transitGSSpreadsheetImportAllBtn),
          subtitle: Text(S.transitGSSpreadsheetImportAllHint),
          trailing: const Icon(Icons.download_for_offline_outlined),
          onTap: () async {
            final confirmed = await ConfirmDialog.show(
              context,
              title: S.transitGSSpreadsheetImportAllConfirmTitle,
              content: S.transitGSSpreadsheetImportAllConfirmContent,
            );

            if (confirmed) {
              import(null);
            }
          },
        ),
        TextDivider(label: S.transitGSSpreadsheetModelImportDivider),
        for (final entry in sheets.entries)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: SheetSelector(
                  key: entry.value,
                  label: entry.key.name,
                  defaultValue: _getSheetName(entry.key.name),
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                tooltip: S.transitImportPreviewBtn,
                icon: const Icon(KIcons.preview),
                onPressed: () => import(entry.key),
              ),
            ]),
          ),
      ],
    );
  }

  @override
  void dispose() {
    for (var sheet in sheets.values) {
      sheet.currentState?.dispose();
    }
    super.dispose();
  }

  /// Reload the sheet names for later import.
  Future<void> reloadSheets(GoogleSpreadsheet ss) async {
    final exist = await widget.exporter.getSheets(ss);

    for (var sheet in sheets.values) {
      sheet.currentState?.setSheets(exist);
    }

    if (mounted) {
      showSnackBar(S.actSuccess, context: context);
    }
  }

  Future<void> import(Formattable? type) async {
    final ss = selector.currentState?.spreadsheet;
    if (ss == null) {
      showSnackBar(S.transitGSErrorImportEmptySpreadsheet, context: context);
      return;
    }

    final selected = sheets.entries
        .where((e) => e.value.currentState?.selected != null)
        .where((e) => type == null || type == e.key)
        .map((e) => MapEntry(e.key, e.value.currentState!.selected!))
        .toList();
    if (selected.isEmpty) {
      showSnackBar(S.transitGSErrorImportEmptySheet, context: context);
      return;
    }

    widget.notifier.value = '_start';

    await showSnackbarWhenFutureError(
      _importSheets(ss, selected),
      'gs_import_failed',
      context: context,
    );

    widget.notifier.value = '_finish';
  }

  /// After verifying the basic data, start importing.
  Future<void> _importSheets(
    GoogleSpreadsheet ss,
    List<MapEntry<Formattable, GoogleSheetProperties>> ableSheets,
  ) async {
    final needPreview = ableSheets.length == 1;
    for (final entry in ableSheets) {
      final able = entry.key;
      final sheet = entry.value;
      widget.notifier.value = S.transitGSModelStatus(able.name);

      if (!await _importData(ss, able, sheet, needPreview)) {
        return;
      }
    }

    if (mounted) {
      showSnackBar(S.actSuccess, context: context);
    }
  }

  Future<void> reloadSheetHints(GoogleSpreadsheet? other) async {
    for (var sheet in sheets.values) {
      sheet.currentState?.setSheets(other!.sheets);
    }
  }

  /// Import the specified form.
  ///
  /// The process is as follows:
  /// 1. Get data
  /// 2. Cache (if possible, preview)
  /// 3. Parse data and import
  Future<bool> _importData(
    GoogleSpreadsheet ss,
    Formattable able,
    GoogleSheetProperties sheet,
    bool needPreview,
  ) async {
    Log.ger('gs_import', {'spreadsheet': ss.id, 'sheet': sheet.title});
    // step 1
    final source = await _requestData(able, ss, sheet);
    if (source == null) {
      if (mounted) {
        showMoreInfoSnackBar(
          S.transitGSErrorImportNotFoundSheets(sheet.title),
          Text(S.transitGSErrorImportNotFoundHelper),
          context: context,
        );
      }
      return false;
    }

    // step 2
    Log.out('received data length: ${source.length}', 'gs_import');
    await _cacheSheetName(able.name, sheet);

    bool? approved = true;
    if (needPreview) {
      approved = await _previewSheetData(able, source);
      if (approved != true) return false;

      approved = await _previewBeforeMerge(able, source);
    } else {
      // merge to stage only (without preview)
      const GoogleSheetFormatter().format(able, source);
    }

    // step 3
    Log.out('parsing table: ${able.name}', 'gs_import');
    await Formatter.finishFormat(able, approved);

    return approved ?? false;
  }

  /// Request the data from the sheet.
  Future<List<List<Object?>>?> _requestData(
    Formattable able,
    GoogleSpreadsheet ss,
    GoogleSheetProperties sheet,
  ) async {
    widget.notifier.value = S.transitGSProgressStatusVerifyUser;
    await widget.exporter.auth();

    const formatter = GoogleSheetFormatter();
    final neededColumns = formatter.getHeader(able).length;
    final sheetData = await widget.exporter.getSheetData(
      ss,
      sheet.title,
      neededColumns: neededColumns,
    );

    // remove header
    final data = sheetData?.sublist(1);
    if (data?.isEmpty != false) {
      return null;
    }

    return data;
  }

  Future<bool?> _previewSheetData(
    Formattable able,
    List<List<Object?>> source,
  ) async {
    const formatter = GoogleSheetFormatter();
    final result = await showAdaptiveDialog(
      context: context,
      builder: (context) => SheetPreviewPage(
        source: SheetPreviewerDataTableSource(source),
        header: formatter.getHeader(able),
        title: S.transitModelName(able.name),
        action: TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(S.transitImportPreviewBtn),
        ),
      ),
    );

    return result;
  }

  Future<bool?> _previewBeforeMerge(
    Formattable able,
    List<List<Object?>> source,
  ) {
    const formatter = GoogleSheetFormatter();
    final formatted = formatter.format(able, source);

    return PreviewPage.show(context, able, formatted);
  }

  GoogleSheetProperties? _getSheetName(String label) {
    final nameId = Cache.instance.get<String>('$_cacheKey.$label');

    return GoogleSheetProperties.fromCacheValue(nameId);
  }

  Future<void> _cacheSheetName(String label, GoogleSheetProperties sheet) async {
    final key = '$_cacheKey.$label';
    if (sheet.toCacheValue() != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, sheet.toCacheValue());
    }
  }
}
