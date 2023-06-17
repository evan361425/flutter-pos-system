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
            onUpdate: _handleSpreadsheetUpdate,
            onExecute: exportData,
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

  @override
  void dispose() {
    for (var sheet in sheets.values) {
      sheet.currentState?.dispose();
    }
    super.dispose();
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

  Future<void> exportData(GoogleSpreadsheet? spreadsheet) async {
    // avoid showing keyboard
    FocusScope.of(context).unfocus();

    final usedSheets = sheets.entries
        .where((entry) => entry.value.currentState?.isUsable == true);
    final names = {
      for (var sheet in usedSheets) sheet.key: sheet.value.currentState!.name,
    };

    if (names.isEmpty) {
      return;
    } else if (names.values.toSet().length != names.length) {
      showSnackBar(context, S.exporterGSErrors('sheetRepeat'));
      return;
    }

    widget.notifier.value = '_start';

    await showSnackbarWhenFailed(
      _exportData(names),
      context,
      'gs_export_failed',
    );

    widget.notifier.value = '_finish';
  }

  /// 檢查基礎資料後，真正開始匯出。
  ///
  /// 1. 準備好表單
  /// 2. 一個一個更新表單
  /// 3. 告知完成
  Future<void> _exportData(Map<Formattable, String> requiredSheets) async {
    // step 1
    final prepared = await _prepareSheets(requiredSheets);
    if (prepared == null) return;

    // step 2
    final ss = spreadsheet!;
    Log.ger('export ready', 'gs_export', ss.id);
    const formatter = GoogleSheetFormatter();
    for (final entry in prepared.entries) {
      final label = entry.key.name;
      widget.notifier.value = S.exporterGSUpdateModelStatus(label);

      await _cacheSheetName(label, entry.value.title);
      await widget.exporter.updateSheet(
        ss,
        entry.value,
        formatter.getRows(entry.key),
        formatter.getHeader(entry.key),
      );
    }

    // step 3
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

  Future<void> _handleSpreadsheetUpdate(GoogleSpreadsheet? other) async {
    for (var sheet in sheets.values) {
      sheet.currentState?.setHints(other?.sheets);
    }

    if (other != null && Cache.instance.get<String>(_importKey) == null) {
      await Cache.instance.set(_importKey, other.toString());
    }
  }

  /// 準備好試算表裡的表單
  ///
  /// 若沒有試算表則建立，若沒有需要的表單（例如菜單表單）也會建立好
  Future<Map<Formattable, GoogleSheetProperties>?> _prepareSheets(
    Map<Formattable, String> requireSheets,
  ) async {
    widget.notifier.value = '驗證身份中';
    await widget.exporter.auth();

    final names = requireSheets.values.toList();
    final ss = spreadsheet;
    if (ss == null) {
      final other = await _createSpreadsheet(names);
      if (other == null) {
        if (mounted) {
          showSnackBar(context, S.exporterGSErrors('spreadsheet'));
        }
        return null;
      }

      await selector.currentState?.update(other);
    } else {
      final existSheets = await widget.exporter.getSheets(ss);
      ss.sheets.addAll(existSheets);
      final success = await _fulfillSheets(ss, names);
      if (!success) {
        if (mounted) {
          showSnackBar(context, S.exporterGSErrors('sheet'));
        }
        return null;
      }
    }

    return {
      for (var e in requireSheets.entries)
        e.key: GoogleSheetProperties(
          spreadsheet!.sheets.firstWhere((sheet) => sheet.title == e.value).id,
          e.value,
          typeName: e.key.name,
        )
    };
  }

  /// 建立試算表
  Future<GoogleSpreadsheet?> _createSpreadsheet(List<String> names) async {
    widget.notifier.value = S.exporterGSProgressStatus('addSpreadsheet');

    return widget.exporter.addSpreadsheet(
      S.exporterGSDefaultSpreadsheetName,
      names,
    );
  }

  /// 補足該試算表的表單
  Future<bool> _fulfillSheets(GoogleSpreadsheet ss, List<String> names) async {
    widget.notifier.value = S.exporterGSProgressStatus('addSheets');

    final exist = ss.sheets.map((e) => e.title).toSet();
    final missing = names.toSet().difference(exist);
    if (missing.isEmpty) {
      return true;
    }

    final added = await widget.exporter.addSheets(ss, missing.toList());
    if (added != null) {
      ss.sheets.addAll(added);
      return true;
    }

    return false;
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
