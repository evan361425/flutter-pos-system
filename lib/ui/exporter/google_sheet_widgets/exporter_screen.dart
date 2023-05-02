import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/formatter/google_sheet_formatter.dart';
import 'package:possystem/helpers/launcher.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';

import 'common.dart';
import 'sheet_namer.dart';
import 'sheet_previewer.dart';

class ExporterScreen extends StatefulWidget {
  final ValueNotifier<String>? notifier;

  final GoogleSheetExporter exporter;

  const ExporterScreen({
    Key? key,
    required this.exporter,
    this.notifier,
  }) : super(key: key);

  @override
  State<ExporterScreen> createState() => _ExporterScreenState();
}

class _ExporterScreenState extends State<ExporterScreen> {
  final sheets = <Formattable, GlobalKey<SheetNamerState>>{
    Formattable.menu: GlobalKey<SheetNamerState>(),
    Formattable.stock: GlobalKey<SheetNamerState>(),
    Formattable.quantities: GlobalKey<SheetNamerState>(),
    Formattable.replenisher: GlobalKey<SheetNamerState>(),
    Formattable.orderAttr: GlobalKey<SheetNamerState>(),
  };

  GoogleSpreadsheet? spreadsheet;

  bool get hasSelect => spreadsheet != null;

  String get exportLabel => hasSelect ? '匯出於指定表單' : '匯出後建立試算單';

  String get hint =>
      hasSelect ? '將匯出於「${spreadsheet?.name}」' : '你尚未選擇試算表，匯出時將建立新的';

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SignInButton(signedInWidget: _signedInWidget),
      const Divider(),
      for (final entry in sheets.entries)
        Row(children: [
          Expanded(
            child: SheetNamer(
              key: entry.value,
              label: entry.key.name,
              sheets: spreadsheet?.sheets,
              initialValue: _getDefault(entry.key.name),
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
            onPressed: () => previewTarget(entry.key),
          ),
        ]),
    ]);
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
        BottomSheetAction(
          title: Text('清除所選並於匯出時建立試算表'),
          leading: Icon(Icons.add_box_outlined),
          returnValue: _ActionTypes.clear,
        ),
      ],
    );

    if (selected == _ActionTypes.select) {
      await selectSheet();
    } else if (selected == _ActionTypes.clear) {
      await onSheetChanged(null);
      if (mounted) {
        showSnackBar(context, S.actSuccess);
      }
    }
  }

  Future<void> onSheetChanged(GoogleSpreadsheet? newSpreadsheet) async {
    Log.ger('change start', 'gs_export', newSpreadsheet?.toString());
    setState(() => spreadsheet = newSpreadsheet);
    for (var sheet in sheets.values) {
      sheet.currentState?.setHints(newSpreadsheet?.sheets);
    }

    if (newSpreadsheet == null) {
      Log.ger('change clear', 'gs_export');
      return;
    }

    final value = newSpreadsheet.toString();
    await Cache.instance.set<String>(exporterCacheKey, value);
    if (Cache.instance.get<String>(importerCacheKey) == null) {
      Log.ger('change success', 'gs_export');
      await Cache.instance.set(importerCacheKey, value);
    }
  }

  Future<void> selectSheet() async {
    widget.notifier?.value = '_start';

    final result = await showSnackbarWhenFailed(
      selectSpreadsheet(context, spreadsheet, widget.exporter),
      context,
      errorCodeSelect,
    );
    if (result != null) {
      await onSheetChanged(result);
      if (mounted) {
        showSnackBar(context, S.actSuccess);
      }
    }

    widget.notifier?.value = '_finish';
  }

  void previewTarget(Formattable able) {
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

  Future<void> exportData() async {
    // avoid showing keyboard
    FocusScope.of(context).unfocus();

    final usedSheets = sheets.entries.where((entry) =>
        entry.value.currentState?.checked == true &&
        entry.value.currentState?.name != null);
    final names = {
      for (var sheet in usedSheets) sheet.key: sheet.value.currentState!.name!,
    };

    if (names.isEmpty) {
      return;
    } else if (names.values.toSet().length != names.length) {
      showSnackBar(context, S.exporterGSErrors('sheetRepeat'));
      return;
    }

    widget.notifier?.value = '_start';

    await showSnackbarWhenFailed(
      _exportData(names),
      context,
      errorCodeExport,
    );

    widget.notifier?.value = '_finish';
  }

  Future<void> _exportData(Map<Formattable, String> names) async {
    final prepared = await _getSpreadsheet(names);
    if (prepared == null) return;

    Log.ger('export ready', 'gs_export', spreadsheet!.id);
    const formatter = GoogleSheetFormatter();
    for (final entry in prepared.entries) {
      final label = entry.key.name;
      widget.notifier?.value = S.exporterGSUpdateModelStatus(label);

      await _setDefault(label, entry.value.title);
      await widget.exporter.updateSheet(
        spreadsheet!,
        entry.value,
        formatter.getRows(entry.key),
        formatter.getHeader(entry.key),
      );
    }

    Log.ger('export finish', 'gs_export');
    if (mounted) {
      showSnackBar(
        context,
        S.actSuccess,
        action: SnackBarAction(
          label: '開啟表單',
          onPressed: () {
            final link = spreadsheet!.toLink();
            Log.ger('export launch', 'gs_export', link);
            Launcher.launch(link).ignore();
          },
        ),
      );
    }
  }

  Future<GoogleSpreadsheet?> _createSpreadsheet(List<String> names) async {
    widget.notifier?.value = S.exporterGSProgressStatus('addSpreadsheet');

    return widget.exporter.addSpreadsheet(
      S.exporterGSDefaultSpreadsheetName,
      names,
    );
  }

  Future<bool> _addSheets(List<String> requiredSheets) async {
    widget.notifier?.value = S.exporterGSProgressStatus('addSheets');

    final exist = spreadsheet!.sheets.map((e) => e.title).toSet();
    final missing = requiredSheets.toSet().difference(exist);
    if (missing.isEmpty) {
      return true;
    }

    final newSheets = await widget.exporter.addSheets(
      spreadsheet!,
      missing.toList(),
    );

    if (newSheets != null) {
      spreadsheet!.sheets.addAll(newSheets);
      return true;
    }

    return false;
  }

  /// 準備好試算表
  ///
  /// 若沒有試算表則建立，若沒有需要的表單（例如菜單表單）也會建立好
  Future<Map<Formattable, GoogleSheetProperties>?> _getSpreadsheet(
    Map<Formattable, String> requireSheets,
  ) async {
    widget.notifier?.value = '驗證身份中';
    await widget.exporter.auth();

    final names = requireSheets.values.toList();
    if (!hasSelect) {
      final newSpreadsheet = await _createSpreadsheet(names);
      if (newSpreadsheet == null) {
        if (mounted) {
          showSnackBar(context, S.exporterGSErrors('spreadsheet'));
        }
        return null;
      }
      await onSheetChanged(newSpreadsheet);
    } else {
      final sheets = await widget.exporter.getSheets(spreadsheet!);
      spreadsheet!.sheets.addAll(sheets);
      final success = await _addSheets(names);
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

  String _getDefault(String label) {
    return Cache.instance.get<String>('$exporterCacheKey.$label') ??
        S.exporterGSDefaultSheetName(label);
  }

  Future<void> _setDefault(String label, String title) async {
    final key = '$exporterCacheKey.$label';
    if (title != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, title);
    }
  }

  Widget _signedInWidget(User user) {
    return Column(children: [
      Row(children: [
        Expanded(
          child: FilledButton(
            onPressed: exportData,
            child: Text(exportLabel),
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
    final cached = Cache.instance.get<String>(exporterCacheKey);
    if (cached != null) {
      spreadsheet = GoogleSpreadsheet.fromString(cached);
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

enum _ActionTypes { select, clear }
