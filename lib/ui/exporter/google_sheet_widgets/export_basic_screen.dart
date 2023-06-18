import 'package:flutter/material.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/style/launcher_snackbar_action.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/formatter/google_sheet_formatter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/spreadsheet_selector.dart';

import 'sheet_namer.dart';
import 'sheet_previewer.dart';

const _cacheKey = 'exporter_google_sheet';
const _importKey = 'importer_google_sheet';

class ExportBasicScreen extends StatefulWidget {
  final ValueNotifier<String> notifier;

  final GoogleSheetExporter exporter;

  const ExportBasicScreen({
    Key? key,
    required this.exporter,
    required this.notifier,
  }) : super(key: key);

  @override
  State<ExportBasicScreen> createState() => _ExportBasicScreenState();
}

class _ExportBasicScreenState extends State<ExportBasicScreen> {
  final sheets = <Formattable, GlobalKey<SheetNamerState>>{
    Formattable.menu: GlobalKey<SheetNamerState>(),
    Formattable.stock: GlobalKey<SheetNamerState>(),
    Formattable.quantities: GlobalKey<SheetNamerState>(),
    Formattable.replenisher: GlobalKey<SheetNamerState>(),
    Formattable.orderAttr: GlobalKey<SheetNamerState>(),
  };

  final selector = GlobalKey<SpreadsheetSelectorState>();

  GoogleSpreadsheet? get spreadsheet {
    if (selector.currentState == null) {
      final cached = Cache.instance.get<String>(_cacheKey);
      if (cached != null) {
        return GoogleSpreadsheet.fromString(cached);
      }
    }

    return selector.currentState?.spreadsheet;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(children: [
        SignInButton(
          signedInWidget: SpreadsheetSelector(
            key: selector,
            exporter: widget.exporter,
            notifier: widget.notifier,
            cacheKey: _cacheKey,
            existLabel: '匯出於指定表單',
            existHint: '將匯出於「%name」',
            emptyLabel: '匯出後建立試算單',
            emptyHint: '你尚未選擇試算表，匯出時將建立新的',
            sheetsToCreate: sheetsToCreate,
            onUpdate: onSpreadsheetUpdate,
            onPrepared: exportData,
          ),
        ),
        const Divider(),
        for (final entry in sheets.entries)
          Row(children: [
            Expanded(
              child: SheetNamer(
                key: entry.value,
                label: entry.key.name,
                sheets: spreadsheet?.sheets,
                initialValue: _getSheetName(entry.key.name),
                initialChecked: Formatter.getTarget(entry.key).isNotEmpty,
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              key: Key('gs_export.${entry.key.name}.preview'),
              constraints: const BoxConstraints(maxHeight: 24),
              icon: const Icon(Icons.remove_red_eye_sharp),
              tooltip: S.exporterGSPreviewerTitle(
                S.exporterGSDefaultSheetName(entry.key.name),
              ),
              onPressed: () => previewData(entry.key),
            ),
          ]),
      ]),
    );
  }

  void previewData(Formattable able) {
    const formatter = GoogleSheetFormatter();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SheetPreviewer(
          source: SheetPreviewerDataTableSource(formatter.getRows(able)),
          header: formatter.getHeader(able),
          title: S.exporterGSDefaultSheetName(able.name),
        ),
      ),
    );
  }

  /// 用來讓 [SpreadsheetSelector] 幫忙建立表單。
  Map<Formattable, String> sheetsToCreate() {
    // avoid showing keyboard
    FocusScope.of(context).unfocus();

    final usedSheets = sheets.entries
        .where((entry) => entry.value.currentState?.isUsable == true);

    return {
      for (var sheet in usedSheets) sheet.key: sheet.value.currentState!.name,
    };
  }

  /// [SpreadsheetSelector] 檢查基礎資料後，真正開始匯出。
  Future<void> exportData(
    GoogleSpreadsheet ss,
    Map<Formattable, GoogleSheetProperties> prepared,
  ) async {
    Future<void> export() async {
      Log.ger('export ready', 'gs_export', ss.id);
      const formatter = GoogleSheetFormatter();

      // cache the sheet names
      for (final e in prepared.entries) {
        await _cacheSheetName(e.key.name, e.value.title);
      }

      // go
      await widget.exporter.updateSheet(
        ss,
        prepared.values,
        prepared.keys.map((key) => formatter.getRows(key)),
        prepared.keys.map((key) => formatter.getHeader(key)),
      );

      Log.ger('export finish', 'gs_export');
      if (mounted) {
        showSnackBar(
          context,
          S.actSuccess,
          action: LauncherSnackbarAction(
            label: '開啟表單',
            link: ss.toLink(),
            logCode: 'gs_export',
          ),
        );
      }
    }

    widget.notifier.value = '_start';

    await showSnackbarWhenFailed(
      export(),
      context,
      'gs_export_failed',
    );

    widget.notifier.value = '_finish';
  }

  Future<void> onSpreadsheetUpdate(GoogleSpreadsheet? other) async {
    for (var sheet in sheets.values) {
      sheet.currentState?.setHints(other?.sheets);
    }

    // 同時更新用作 import 的試算表
    if (other != null && Cache.instance.get<String>(_importKey) == null) {
      await Cache.instance.set(_importKey, other.toString());
    }
  }

  String _getSheetName(String label) {
    return Cache.instance.get<String>('$_cacheKey.$label') ??
        S.exporterGSDefaultSheetName(label);
  }

  Future<void> _cacheSheetName(String label, String title) async {
    final key = '$_cacheKey.$label';
    if (title != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, title);
    }
  }
}
