import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/formatter/google_sheet_formatter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/spreadsheet_selector.dart';
import 'package:possystem/ui/exporter/previews/previewer_screen.dart';

import 'sheet_previewer.dart';
import 'sheet_selector.dart';

const _cacheKey = 'importer_google_sheet';

class ImportBasicScreen extends StatefulWidget {
  final ValueNotifier<String> notifier;

  final GoogleSheetExporter exporter;

  const ImportBasicScreen({
    Key? key,
    required this.exporter,
    required this.notifier,
  }) : super(key: key);

  @override
  State<ImportBasicScreen> createState() => _ImportBasicScreenState();
}

class _ImportBasicScreenState extends State<ImportBasicScreen> {
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          SignInButton(
            signedInWidget: SpreadsheetSelector(
              key: selector,
              exporter: widget.exporter,
              notifier: widget.notifier,
              cacheKey: _cacheKey,
              existLabel: '檢查試算表',
              existHint: '將匯入於「%name」',
              emptyLabel: '選擇試算表',
              emptyHint: '開始選擇試算表後，方能匯入資料',
              onUpdate: reloadSheetHints,
              onChoose: reloadSheets,
            ),
          ),
          const Divider(),
          ElevatedButton(
            key: const Key('gs_export.import_all'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: '確定要匯入全部嗎？',
                content: '將會把所選的資料「都覆蓋掉」，請確認是否執行。',
              );

              if (confirmed) {
                importData(null);
              }
            },
            child: const Text('匯入全部'),
          ),
          const SizedBox(height: 8.0),
          for (final entry in sheets.entries)
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: SheetSelector(
                  key: entry.value,
                  label: entry.key.name,
                  defaultValue: _getSheetName(entry.key.name),
                ),
              ),
              const SizedBox(width: 8.0),
              OutlinedButton.icon(
                onPressed: () => importData(entry.key),
                label: const Text('預覽結果'),
                icon: const Icon(Icons.download_for_offline_outlined),
              ),
            ]),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var sheet in sheets.values) {
      sheet.currentState?.dispose();
    }
    super.dispose();
  }

  /// 重新讀取試算表的表單名稱
  Future<void> reloadSheets(GoogleSpreadsheet ss) async {
    final exist = await widget.exporter.getSheets(ss);

    for (var sheet in sheets.values) {
      sheet.currentState?.setSheets(exist);
    }

    if (mounted) {
      showSnackBar(context, S.actSuccess);
    }
  }

  Future<void> importData(Formattable? type) async {
    final ss = selector.currentState?.spreadsheet;
    if (ss == null) {
      showSnackBar(context, S.importerGSError('emptySpreadsheet'));
      return;
    }

    final selected = sheets.entries
        .where((e) => e.value.currentState?.selected != null)
        .where((e) => type == null || type == e.key)
        .map((e) => MapEntry(e.key, e.value.currentState!.selected!))
        .toList();
    if (selected.isEmpty) {
      showSnackBar(context, S.importerGSError('emptySheet'));
      return;
    }

    widget.notifier.value = '_start';

    await showSnackbarWhenFailed(
      _importData(ss, selected),
      context,
      'gs_import_failed',
    );

    widget.notifier.value = '_finish';
  }

  /// 檢查基礎資料後，真正開始匯入。
  ///
  /// 1. 取得資料
  /// 2. 快取（如果可能的話，預覽）
  /// 3. 解析資料並匯入
  Future<void> _importData(
    GoogleSpreadsheet ss,
    List<MapEntry<Formattable, GoogleSheetProperties>> ableSheets,
  ) async {
    final allowPreview = ableSheets.length == 1;
    for (final entry in ableSheets) {
      final able = entry.key;
      final sheet = entry.value;
      widget.notifier.value = S.exporterGSUpdateModelStatus(able.name);

      // step 1
      Log.ger('ready', 'gs_import', sheet.title);
      final source = await _requestData(able, ss, sheet);
      if (source == null) {
        if (mounted) {
          showSnackBar(context, '找不到表單「${sheet.title}」的資料');
        }
        return;
      }

      // step 2
      Log.ger('received', 'gs_import', source.length.toString());
      await _cacheSheetName(able.name, sheet);

      if (allowPreview) {
        final approved = await _previewSheetData(able, source);
        if (approved != true) return;
      }

      // step 3
      Log.ger('parsing', 'gs_import', able.name);
      final allowSave = await _parsedData(able, source, preview: allowPreview);
      await Formatter.finishFormat(able, allowSave);
    }
    if (mounted) {
      showSnackBar(context, S.actSuccess);
    }
  }

  Future<void> reloadSheetHints(GoogleSpreadsheet? other) async {
    for (var sheet in sheets.values) {
      sheet.currentState?.setSheets(other!.sheets);
    }
  }

  /// 請求表單的資料
  Future<List<List<Object?>>?> _requestData(
    Formattable able,
    GoogleSpreadsheet ss,
    GoogleSheetProperties sheet,
  ) async {
    widget.notifier.value = '驗證身份中';
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
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => SheetPreviewer(
          source: SheetPreviewerDataTableSource(source),
          header: formatter.getHeader(able),
          title: S.exporterTypeName(able.name),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(S.importPreviewerTitle),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  Future<bool?> _parsedData(
    Formattable able,
    List<List<Object?>> source, {
    required bool preview,
  }) {
    const formatter = GoogleSheetFormatter();
    final formatted = formatter.format(able, source);

    return preview
        ? PreviewerScreen.navByAble(context, able, formatted)
        : Future.value(true);
  }

  GoogleSheetProperties? _getSheetName(String label) {
    final nameId = Cache.instance.get<String>('$_cacheKey.$label');

    return GoogleSheetProperties.fromCacheValue(nameId);
  }

  Future<void> _cacheSheetName(
      String label, GoogleSheetProperties sheet) async {
    final key = '$_cacheKey.$label';
    if (sheet.toCacheValue() != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, sheet.toCacheValue());
    }
  }
}
