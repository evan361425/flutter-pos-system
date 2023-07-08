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
  late final List<SheetNamerProperties> sheets;

  final selector = GlobalKey<SpreadsheetSelectorState>();

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
            existLabel: '匯出於指定試算表',
            existHint: '將匯出於「%name」',
            emptyLabel: '匯出後建立試算單',
            emptyHint: '你尚未選擇試算表，匯出時將建立新的',
            sheetsToCreate: sheetsToCreate,
            onUpdate: onSpreadsheetUpdate,
            onPrepared: exportData,
          ),
        ),
        const Divider(),
        for (final sheet in sheets)
          SheetNamer(
            prop: sheet,
            action: (prop) => previewData(prop.type),
            actionIcon: Icons.remove_red_eye_sharp,
            actionTitle: AutofillHints.addressCity,
          ),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    sheets = [
      SheetType.menu,
      SheetType.stock,
      SheetType.quantities,
      SheetType.replenisher,
      SheetType.orderAttr,
    ].map((e) {
      final name = Cache.instance.get<String>('$_cacheKey.${e.name}') ??
          S.exporterTypeName(e.name);
      final data = Formatter.getTarget(Formatter.nameToFormattable(e.name));

      return SheetNamerProperties(
        e,
        name: name,
        checked: data.isNotEmpty,
        hints: spreadsheet?.sheets.map((e) => e.title),
      );
    }).toList();
  }

  GoogleSpreadsheet? get spreadsheet {
    if (selector.currentState == null) {
      final cached = Cache.instance.get<String>(_cacheKey);
      if (cached != null) {
        return GoogleSpreadsheet.fromString(cached);
      }
    }

    return selector.currentState?.spreadsheet;
  }

  void previewData(SheetType type) {
    const formatter = GoogleSheetFormatter();
    final able = Formatter.nameToFormattable(type.name);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SheetPreviewer(
          source: SheetPreviewerDataTableSource(formatter.getRows(able)),
          header: formatter.getHeader(able),
          title: S.exporterTypeName(able.name),
        ),
      ),
    );
  }

  /// 用來讓 [SpreadsheetSelector] 幫忙建立表單。
  Map<SheetType, String> sheetsToCreate() => {
        for (var sheet in sheets.where((sheet) => sheet.checked))
          sheet.type: sheet.name,
      };

  /// [SpreadsheetSelector] 檢查基礎資料後，真正開始匯出。
  Future<void> exportData(
    GoogleSpreadsheet ss,
    Map<SheetType, GoogleSheetProperties> kv,
  ) async {
    Log.ger('export ready', 'gs_export', ss.id);
    const formatter = GoogleSheetFormatter();

    // cache the sheet names
    final prepared = kv.map((key, value) => MapEntry(
          Formattable.values.firstWhere((e) => e.name == key.name),
          value,
        ));
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

  Future<void> onSpreadsheetUpdate(GoogleSpreadsheet? other) async {
    for (final sheet in sheets) {
      sheet.hints = other?.sheets.map((e) => e.title);
    }

    // 同時更新用作 import 的試算表
    if (other != null && Cache.instance.get<String>(_importKey) == null) {
      await Cache.instance.set(_importKey, other.toString());
    }
  }

  Future<void> _cacheSheetName(String label, String title) async {
    final key = '$_cacheKey.$label';
    if (title != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, title);
    }
  }
}
