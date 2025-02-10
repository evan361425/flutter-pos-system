import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/transit/formatter/field_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/google_sheet/spreadsheet_dialog.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ImportBasicView extends StatefulWidget {
  final TransitStateNotifier stateNotifier;

  final GoogleSheetExporter exporter;

  const ImportBasicView({
    super.key,
    required this.exporter,
    required this.stateNotifier,
  });

  @override
  State<ImportBasicView> createState() => _ImportBasicViewState();
}

class _ImportBasicViewState extends State<ImportBasicView> {
  final ValueNotifier<FormattableModel?> model = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SignInButton(
            signedInWidget: ModelPicker(
              selected: model,
              onTap: _import,
              allWarning: S.transitGSSpreadsheetImportAllHint,
              icon: Icon(Icons.cloud_download_sharp, semanticLabel: S.transitImportBtn),
            ),
          ),
        ),
      ],
    );
  }

  void _import(FormattableModel? able) {
    widget.stateNotifier.exec(
      () => showSnackbarWhenFutureError(
        _startImport(able),
        'excel_import_failed',
        context: context,
      ).then((success) {
        if (success == true) {
          // ignore: use_build_context_synchronously
          showSnackBar(S.actSuccess, context: context);
        }
      }),
    );
  }

  /// Import all data from spreadsheet.
  ///
  /// 1. Ask user to select a spreadsheet.
  /// 2. Verify all sheets are exist.
  /// 3. Import each sheet one by one.
  Future<bool?> _startImport(FormattableModel? able) async {
    // Step 1
    GoogleSpreadsheet? ss = await SpreadsheetDialog.show(
      context,
      exporter: widget.exporter,
      cacheKey: importCacheKey,
      fallbackCacheKey: exportCacheKey,
    );
    if (ss == null || !mounted) {
      return false;
    }

    // Step 2
    final titles = able?.toL10nNames() ?? FormattableModel.allL10nNames;
    final wanted = titles.toSet();
    if (!ss.containsAll(wanted)) {
      final requested = await widget.exporter.getSheets(ss);
      ss.merge(requested);
    }

    final exist = ss.sheets.map((e) => e.title).toSet();
    final missing = wanted.difference(exist);
    if (missing.isNotEmpty) {
      // ignore: use_build_context_synchronously
      showSnackBar(S.transitGSErrorImportNotFoundSheets(missing.join(', ')), context: context);
      return false;
    }

    // Step 3
    // TODO: update l10n
    widget.stateNotifier.value = S.transitGSModelStatus('start');
    Log.ger('gs_import', {'spreadsheet': ss.id, 'sheets': titles});

    final ables = able?.toList() ?? FormattableModel.values;
    final sheets = titles.map((title) => ss.sheets.firstWhere((e) => e.title == title)).toList();
    final needPreview = sheets.length == 1;
    for (final [a, b] in IterableZip([ables, sheets])) {
      final ok = await _importData(ss, a as FormattableModel, b as GoogleSheetProperties, needPreview);
      if (ok != true) {
        return false;
      }
    }

    return true;
  }

  /// Import specific sheet data.
  ///
  /// 1. Fetch data from remote.
  /// 2. Parse and preview if [preview] is true else directly import.
  Future<bool?> _importData(
    GoogleSpreadsheet ss,
    FormattableModel able,
    GoogleSheetProperties sheet,
    bool preview,
  ) async {
    // step 1
    Log.out('start import ${able.name} sheet: ${sheet.title}', 'gs_import');
    final source = await _requestData(able, ss, sheet);
    if (source == null) {
      showMoreInfoSnackBar(
        S.transitGSErrorImportNotFoundSheets(sheet.title),
        Text(S.transitGSErrorImportNotFoundHelper),
        // ignore: use_build_context_synchronously
        context: context,
      );
      return false;
    }

    // step 2
    Log.out('received data length: ${source.length}', 'gs_import');
    bool? allowed = true;
    if (preview) {
      bool? allowed;
      if (mounted) {
        allowed = await PreviewPage.show(
          context,
          able: able,
          items: findFieldFormatter(able).format(source),
          commitAfter: true,
        );
      }

      return allowed;
    }

    findFieldFormatter(able).format(source);
    await able.finishPreview(allowed);

    return true;
  }

  /// Request the data from the sheet.
  Future<List<List<Object?>>?> _requestData(
    FormattableModel able,
    GoogleSpreadsheet ss,
    GoogleSheetProperties sheet,
  ) async {
    widget.stateNotifier.value = S.transitGSProgressStatusVerifyUser;
    await widget.exporter.auth();

    final formatter = findFieldFormatter(able);
    final neededColumns = formatter.getHeader().length;
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
}
