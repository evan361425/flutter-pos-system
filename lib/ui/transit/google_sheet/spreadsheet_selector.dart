import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';

final _sheetUrlRegex = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]{15,})/');
final _sheetIdRegex = RegExp(r'^([a-zA-Z0-9-_]{15,})$');
const _sheetTutorial =
    "https://raw.githubusercontent.com/evan361425/flutter-pos-system/master/assets/web/tutorial-gs-copy-url.gif";

class SpreadsheetSelector extends StatefulWidget {
  final GoogleSheetExporter exporter;

  final ValueNotifier<String>? notifier;

  /// 快取的鍵
  final String cacheKey;

  // 允許設定一個預設的表單
  final String fallbackCacheKey;

  // 預設的試算表名稱
  final String defaultName;

  /// 試算表存在的話，按鈕的文字
  final String existLabel;

  /// 試算表不存在的話，按鈕的文字
  final String emptyLabel;

  /// 試算表存在的話，按鈕下方的文字。
  /// %name 可以替代為現在的 spreadsheet 名稱
  final String existHint;

  /// 試算表不存在的話，按鈕下方的文字
  final String emptyHint;

  /// 試算表被更新了
  final Future<void> Function(GoogleSpreadsheet? spreadsheet)? onUpdated;

  /// 根據選擇好的試算表去執行某些行為，例如匯入
  final Future<void> Function(GoogleSpreadsheet spreadsheet)? onChosen;

  /// 根據選擇好的試算表並且準備好 [sheetsToCreate] 的表單後，去執行某些行為，例如匯出
  final Future<void> Function(
    GoogleSpreadsheet spreadsheet,
    Map<SheetType, GoogleSheetProperties> sheets,
  )? onPrepared;

  /// 若設定此值，代表允許建立試算表，並同時準備好該試算表的部分表單
  final Map<SheetType, String> Function()? requiredSheetTitles;

  const SpreadsheetSelector({
    Key? key,
    required this.exporter,
    required this.cacheKey,
    required this.existLabel,
    required this.emptyLabel,
    required this.existHint,
    required this.emptyHint,
    this.fallbackCacheKey = '_',
    this.defaultName = '',
    this.onChosen,
    this.onPrepared,
    this.onUpdated,
    this.requiredSheetTitles,
    this.notifier,
  }) : super(key: key);

  @override
  State<SpreadsheetSelector> createState() => SpreadsheetSelectorState();

  GoogleSpreadsheet? get defaultSpreadsheet {
    final cached = Cache.instance.get<String>(cacheKey) ??
        Cache.instance.get<String>(fallbackCacheKey);
    if (cached != null) {
      return GoogleSpreadsheet.fromString(cached);
    }

    return null;
  }
}

class SpreadsheetSelectorState extends State<SpreadsheetSelector> {
  GoogleSpreadsheet? spreadsheet;

  bool get isExist => spreadsheet != null;

  String get label => isExist ? widget.existLabel : widget.emptyLabel;

  String get hint => (isExist
      ? widget.existHint.replaceFirst('%name', spreadsheet!.name)
      : widget.emptyHint);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(hint),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        onTap: execute,
        trailing: IconButton(
          onPressed: showActions,
          icon: const Icon(KIcons.more),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    spreadsheet = widget.defaultSpreadsheet;
  }

  Future<void> showActions() async {
    final selected = await showCircularBottomSheet<_ActionTypes>(
      context,
      actions: <BottomSheetAction<_ActionTypes>>[
        const BottomSheetAction(
          title: Text('選擇試算表'),
          leading: Icon(Icons.file_open_outlined),
          returnValue: _ActionTypes.choose,
        ),
        if (widget.requiredSheetTitles != null)
          const BottomSheetAction(
            title: Text('清除所選'),
            leading: Icon(Icons.cleaning_services_outlined),
            returnValue: _ActionTypes.clear,
          ),
      ],
    );

    if (selected != null) {
      switch (selected) {
        case _ActionTypes.choose:
          await choose();
          break;
        case _ActionTypes.clear:
          await clear();
          break;
      }
    }
  }

  // 執行要求的函式
  void execute() async {
    await showSnackbarWhenFailed(
      _execute(),
      context,
      '${widget.cacheKey}_failed',
    );

    _notify('_finish');
  }

  // 選擇試算表
  Future<void> choose() async {
    _notify('_start');

    await showSnackbarWhenFailed(
      _choose(),
      context,
      'gs_select_request_failed',
    );

    _notify('_finish');
  }

  // 清除所選的試算表
  Future<void> clear() async {
    await _update(null);

    if (mounted) {
      showSnackBar(context, S.actSuccess);
    }
  }

  void _notify(String signal) {
    if (widget.notifier != null) {
      widget.notifier!.value = signal;
    }
  }

  Future<void> _execute() async {
    final requiredSheetTitles = widget.requiredSheetTitles;
    // 如果不能建立，就再去跟使用者要一次
    if (requiredSheetTitles == null) {
      _notify('_start');
      if (!isExist) {
        await _choose();
      }

      // 剛剛有成功要到或者本來就有
      if (isExist) {
        await widget.onChosen?.call(spreadsheet!);
      }
      return;
    }

    final confirmed = await ConfirmDialog.show(
      context,
      title: '確認執行$label嗎？',
      content: '將會$hint',
    );

    if (confirmed) {
      _notify('_start');
      // 建立並且回應
      final sheets = await _prepare(spreadsheet, requiredSheetTitles());
      if (sheets != null) {
        await widget.onPrepared?.call(spreadsheet!, sheets);
      }
    }
  }

  Future<void> _choose() async {
    final id = await showDialog<String>(
      context: context,
      builder: (context) {
        return SingleTextDialog(
          header: CachedNetworkImage(
            imageUrl: _sheetTutorial,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
          ),
          initialValue: spreadsheet?.id,
          decoration: InputDecoration(
            labelText: S.transitGSSpreadsheetLabel,
            helperText: spreadsheet?.name == null
                ? '輸入試算表網址或試算表 ID'
                : '本試算表為「${spreadsheet?.name}」',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            errorMaxLines: 5,
          ),
          autofocus: false,
          selectAll: true,
          validator: _spreadsheetValidator,
          formatter: _spreadsheetFormatter,
        );
      },
    );
    if (id == null) return;

    final result = await widget.exporter.getSpreadsheet(id);

    if (result != null) {
      await _update(result);
      if (mounted) {
        showSnackBar(context, S.actSuccess);
      }
    } else if (mounted) {
      showMoreInfoSnackBar(
        context,
        '找不到表單',
        MetaBlock.withString(context, [
          '別擔心，通常都可以簡單解決！可能的原因有：\n',
          '網路狀況不穩；\n',
          '該表單被限制存取了，請打開權限；\n',
          '打錯了，請嘗試複製整個網址後貼上；\n',
          '該表單被刪除了。',
        ])!,
      );
    }
  }

  Future<void> _update(GoogleSpreadsheet? other) async {
    Log.ger('change start', 'gs_export', other.toString());
    setState(() => spreadsheet = other);
    await widget.onUpdated?.call(other);

    if (other != null) {
      await Cache.instance.set<String>(widget.cacheKey, other.toString());
    }
  }

  /// 準備好試算表裡的表單
  ///
  /// 若沒有試算表則建立，並建立所有可能的表單。
  /// 若有則把需要的表單準備好。
  Future<Map<SheetType, GoogleSheetProperties>?> _prepare(
    GoogleSpreadsheet? ss,
    Map<SheetType, String> sheets,
  ) async {
    if (sheets.isEmpty) {
      showSnackBar(context, S.transitGSErrors('sheetEmpty'));
      return null;
    }

    if (sheets.values.toSet().length != sheets.length) {
      showSnackBar(context, S.transitGSErrors('sheetRepeat'));
      return null;
    }

    _notify('驗證身份中');

    await widget.exporter.auth();

    final names = sheets.values.toList();
    if (ss == null) {
      _notify(S.transitGSProgressStatus('addSpreadsheet'));

      final other = await widget.exporter.addSpreadsheet(
        widget.defaultName,
        names,
      );
      if (other == null) {
        if (mounted) {
          showSnackBar(context, S.transitGSErrors('spreadsheet'));
        }
        return null;
      }

      await _update(other);
      ss = other;
    } else {
      final existSheets = await widget.exporter.getSheets(ss);
      ss.sheets.addAll(existSheets);

      final success = await _fulfillSheets(ss, names);
      if (!success) {
        if (mounted) {
          showSnackBar(context, S.transitGSErrors('sheet'));
        }
        return null;
      }
    }

    return {
      for (var e in sheets.entries)
        e.key: GoogleSheetProperties(
          ss.sheets.firstWhere((sheet) => sheet.title == e.value).id,
          e.value,
          typeName: e.key.name,
        )
    };
  }

  /// 補足該試算表的表單
  Future<bool> _fulfillSheets(GoogleSpreadsheet ss, List<String> names) async {
    final exist = ss.sheets.map((e) => e.title).toSet();
    final missing = names.toSet().difference(exist);
    if (missing.isEmpty) {
      return true;
    }

    _notify(S.transitGSProgressStatus('addSheets'));
    final added = await widget.exporter.addSheets(ss, missing.toList());
    if (added != null) {
      ss.sheets.addAll(added);
      return true;
    }

    return false;
  }
}

String? _spreadsheetValidator(String? text) {
  if (text == null || text.isEmpty) return '不能為空';

  if (!_sheetUrlRegex.hasMatch(text) && !_sheetIdRegex.hasMatch(text)) {
    return '不合法的文字，必須包含：\n'
        '/spreadsheets/d/<ID>/\n'
        '或者直接給 ID（英文+數字+底線+減號的組合）';
  }

  return null;
}

/// [_spreadsheetValidator] has already make sure [text] is not null
String? _spreadsheetFormatter(String? text) {
  final urlResult = _sheetUrlRegex.firstMatch(text!);

  if (urlResult != null) {
    return urlResult.group(1);
  }

  return _sheetIdRegex.firstMatch(text)?.group(0);
}

enum _ActionTypes { choose, clear }

enum SheetType {
  menu,
  stock,
  quantities,
  replenisher,
  orderAttr,
  order,
  orderSetAttr,
  orderProduct,
  orderIngredient,
}
