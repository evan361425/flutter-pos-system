import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/meta_block.dart';
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
    Key? key,
    required this.exporter,
    required this.notifier,
  }) : super(key: key);

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
          padding: const EdgeInsets.all(8.0),
          child: SignInButton(
            signedInWidget: SpreadsheetSelector(
              key: selector,
              exporter: widget.exporter,
              notifier: widget.notifier,
              cacheKey: _cacheKey,
              existLabel: '確認表單名稱',
              existHint: '從試算表中取得所有表單的名稱，並進行匯入',
              emptyLabel: '選擇試算表',
              emptyHint: '選擇要匯入的試算表後，就能開始匯入資料',
              onUpdated: reloadSheetHints,
              onChosen: reloadSheets,
            ),
          ),
        ),
        ListTile(
          key: const Key('gs_export.import_all'),
          title: const Text('匯入全部'),
          subtitle: const Text('不會有任何預覽畫面，直接覆寫全部的資料。'),
          trailing: const Icon(Icons.download_for_offline_sharp),
          onTap: () async {
            final confirmed = await ConfirmDialog.show(
              context,
              title: '匯入全部資料？',
              content: '將會把所選表單的資料都下載，並完全覆蓋本地資料。\n此動作無法復原。',
            );

            if (confirmed) {
              import(null);
            }
          },
        ),
        const TextDivider(label: '選擇欲匯入表單'),
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
                tooltip: '預覽結果並匯入',
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

  Future<void> import(Formattable? type) async {
    final ss = selector.currentState?.spreadsheet;
    if (ss == null) {
      showSnackBar(context, S.transitGSImportError('emptySpreadsheet'));
      return;
    }

    final selected = sheets.entries
        .where((e) => e.value.currentState?.selected != null)
        .where((e) => type == null || type == e.key)
        .map((e) => MapEntry(e.key, e.value.currentState!.selected!))
        .toList();
    if (selected.isEmpty) {
      showSnackBar(context, S.transitGSImportError('emptySheet'));
      return;
    }

    widget.notifier.value = '_start';

    await showSnackbarWhenFailed(
      _importSheets(ss, selected),
      context,
      'gs_import_failed',
    );

    widget.notifier.value = '_finish';
  }

  /// 檢查基礎資料後，真正開始匯入。
  Future<void> _importSheets(
    GoogleSpreadsheet ss,
    List<MapEntry<Formattable, GoogleSheetProperties>> ableSheets,
  ) async {
    final needPreview = ableSheets.length == 1;
    for (final entry in ableSheets) {
      final able = entry.key;
      final sheet = entry.value;
      widget.notifier.value = S.transitGSUpdateModelStatus(able.name);

      if (!await _importData(ss, able, sheet, needPreview)) {
        return;
      }
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

  /// 匯入指定表單。
  ///
  /// 1. 取得資料
  /// 2. 快取（如果可能的話，預覽）
  /// 3. 解析資料並匯入
  Future<bool> _importData(
    GoogleSpreadsheet ss,
    Formattable able,
    GoogleSheetProperties sheet,
    bool needPreview,
  ) async {
    // step 1
    Log.ger('ready', 'gs_import', sheet.title);
    final source = await _requestData(able, ss, sheet);
    if (source == null) {
      if (mounted) {
        showMoreInfoSnackBar(
          context,
          '找不到表單「${sheet.title}」的資料',
          MetaBlock.withString(
              context,
              [
                '別擔心，通常都可以簡單解決！\n可能的原因有：\n',
                '網路狀況不穩；\n',
                '尚未進行授權；\n',
                '表單 ID 打錯了，請嘗試複製整個網址後貼上；\n',
                '該表單被刪除了。',
              ],
              textOverflow: TextOverflow.visible)!,
        );
      }
      return false;
    }

    // step 2
    Log.ger('received', 'gs_import', source.length.toString());
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
    Log.ger('parsing', 'gs_import', able.name);
    await Formatter.finishFormat(able, approved);

    return approved ?? false;
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
        builder: (context) => SheetPreviewPage(
          source: SheetPreviewerDataTableSource(source),
          header: formatter.getHeader(able),
          title: S.transitType(able.name),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(S.transitPreviewImportTitle),
            ),
          ],
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

  Future<void> _cacheSheetName(
      String label, GoogleSheetProperties sheet) async {
    final key = '$_cacheKey.$label';
    if (sheet.toCacheValue() != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, sheet.toCacheValue());
    }
  }
}
