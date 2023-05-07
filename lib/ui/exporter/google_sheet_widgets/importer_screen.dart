import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/formatter/google_sheet_formatter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/previews/previewer_screen.dart';

import 'common.dart';
import 'sheet_previewer.dart';
import 'sheet_selector.dart';

class ImporterScreen extends StatefulWidget {
  final ValueNotifier<String> notifier;

  final GoogleSheetExporter exporter;

  const ImporterScreen({
    Key? key,
    required this.exporter,
    required this.notifier,
  }) : super(key: key);

  @override
  State<ImporterScreen> createState() => _ImporterScreenState();
}

class _ImporterScreenState extends State<ImporterScreen> {
  final sheets = <Formattable, GlobalKey<SheetSelectorState>>{
    Formattable.menu: GlobalKey<SheetSelectorState>(),
    Formattable.stock: GlobalKey<SheetSelectorState>(),
    Formattable.quantities: GlobalKey<SheetSelectorState>(),
    Formattable.replenisher: GlobalKey<SheetSelectorState>(),
    Formattable.orderAttr: GlobalKey<SheetSelectorState>(),
  };

  GoogleSpreadsheet? spreadsheet;

  bool get hasSelect => spreadsheet != null;

  String get prepareLabel => hasSelect ? '檢查所選的試算表' : '選擇試算表';

  String get hint =>
      hasSelect ? '將於「${spreadsheet?.name}」匯入' : '你尚未選擇試算表，將無法匯入';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SignInButton(signedInWidget: _signedInWidget),
        const Divider(),
        FilledButton(
          key: const Key('gs_export.import_all'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(40),
          ),
          onPressed: () async {
            final confirmed = await ConfirmDialog.show(
              context,
              title: '確定要匯入全部嗎？',
              content: '匯入全部資料將會把所選的表單資料都覆蓋掉既有資料。',
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
                defaultValue: _getDefault(entry.key.name),
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
    );
  }

  Future<void> showActions() async {
    final selected = await showCircularBottomSheet<_ActionTypes>(
      context,
      actions: const <BottomSheetAction<_ActionTypes>>[
        BottomSheetAction(
          title: Text('選擇試算表'),
          leading: Icon(Icons.list_alt_sharp),
          returnValue: _ActionTypes.select,
        ),
      ],
    );

    if (selected == _ActionTypes.select) {
      await selectSheet();
    }
  }

  Future<void> changeSpreadsheet(GoogleSpreadsheet newSpreadsheet) async {
    Log.ger('change start', 'gs_import', newSpreadsheet.toString());

    setState(() => spreadsheet = newSpreadsheet);
    for (var sheet in sheets.values) {
      sheet.currentState?.setSheets(newSpreadsheet.sheets);
    }

    await Cache.instance
        .set<String>(importerCacheKey, newSpreadsheet.toString());
    Log.ger('change finish', 'gs_import');
  }

  Future<void> selectSheet() async {
    widget.notifier.value = '_start';

    final result = await showSnackbarWhenFailed(
      selectSpreadsheet(context, spreadsheet, widget.exporter),
      context,
      errorCodeSelect,
    );
    if (result != null) {
      await changeSpreadsheet(result);
      if (mounted) {
        showSnackBar(context, S.actSuccess);
      }
    }

    widget.notifier.value = '_finish';
  }

  Future<void> refreshSheet() async {
    assert(hasSelect);

    widget.notifier.value = '_start';

    await showSnackbarWhenFailed(
      _refreshSheet(spreadsheet!),
      context,
      errorCodeRefresh,
    );

    widget.notifier.value = '_finish';
  }

  Future<void> importData(Formattable? type) async {
    if (!hasSelect) {
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
      _importData(selected),
      context,
      errorCodeImport,
    );

    widget.notifier.value = '_finish';
  }

  Future<void> _refreshSheet(GoogleSpreadsheet spreadsheet) async {
    final refreshedSheets = await widget.exporter.getSheets(spreadsheet);

    for (var sheet in sheets.values) {
      sheet.currentState?.setSheets(refreshedSheets);
    }
    if (mounted) {
      showSnackBar(context, S.actSuccess);
    }
  }

  Future<void> _importData(
    List<MapEntry<Formattable, GoogleSheetProperties>> data,
  ) async {
    final allowPreview = data.length == 1;
    for (final entry in data) {
      final able = entry.key;
      final sheet = entry.value;
      final msg = S.exporterGSUpdateModelStatus(able.name);
      widget.notifier.value = msg;

      Log.ger('ready', 'gs_import', sheet.title);
      final source = await _getSheetData(able, sheet);
      if (source == null) {
        if (mounted) {
          showSnackBar(context, '找不到表單「${sheet.title}」的資料');
        }
        return;
      }

      Log.ger('received', 'gs_import', source.length.toString());
      await _setDefault(able.name, sheet);

      if (allowPreview) {
        final allowPreviewFormed = await _previewSheetData(able, source);
        if (allowPreviewFormed != true) return;
      }

      Log.ger('parsing', 'gs_import', able.name);
      final allowSave = await _parsedData(able, source, preview: allowPreview);
      await Formatter.finishFormat(able, allowSave);
    }
    if (mounted) {
      showSnackBar(context, S.actSuccess);
    }
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
          title: S.exporterGSDefaultSheetName(able.name),
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

  Future<List<List<Object?>>?> _getSheetData(
    Formattable able,
    GoogleSheetProperties sheet,
  ) async {
    widget.notifier.value = '驗證身份中';
    await widget.exporter.auth();

    const formatter = GoogleSheetFormatter();
    final neededColumns = formatter.getHeader(able).length;

    final sheetData = await widget.exporter.getSheetData(
      spreadsheet!,
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

  Future<void> _setDefault(String label, GoogleSheetProperties sheet) async {
    final key = '$importerCacheKey.$label';
    if (sheet.toCacheValue() != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, sheet.toCacheValue());
    }
  }

  GoogleSheetProperties? _getDefault(String label) {
    final nameId = Cache.instance.get<String>('$importerCacheKey.$label');

    return GoogleSheetProperties.fromCacheValue(nameId);
  }

  Widget _signedInWidget(User user) {
    return Column(children: [
      Row(children: [
        Expanded(
          child: FilledButton(
            onPressed: () async {
              await (hasSelect ? refreshSheet() : selectSheet());
            },
            child: Text(prepareLabel),
          ),
        ),
        IconButton(
          onPressed: showActions,
          icon: const Icon(Icons.more_vert_sharp),
        ),
      ]),
      HintText(hint),
    ]);
  }

  @override
  void initState() {
    final value = Cache.instance.get<String>(importerCacheKey);
    if (value != null) {
      spreadsheet = GoogleSpreadsheet.fromString(value);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (var sheet in sheets.values) {
      sheet.currentState?.dispose();
    }
    super.dispose();
  }
}

enum _ActionTypes { select }
