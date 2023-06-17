import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
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

  /// 是否要求必須要選擇一個試算表
  final bool forceExist;

  /// 快取的鍵
  final String cacheKey;

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
  final Future<void> Function(GoogleSpreadsheet? spreadsheet)? onUpdate;

  /// 根據選擇好（或沒選）的試算表去執行某些行為，例如匯出或匯入
  final Future<void> Function(GoogleSpreadsheet? spreadsheet) onExecute;

  const SpreadsheetSelector({
    Key? key,
    required this.exporter,
    required this.cacheKey,
    required this.existLabel,
    required this.emptyLabel,
    required this.existHint,
    required this.emptyHint,
    required this.onExecute,
    this.onUpdate,
    this.forceExist = false,
    this.notifier,
  }) : super(key: key);

  @override
  State<SpreadsheetSelector> createState() => SpreadsheetSelectorState();

  GoogleSpreadsheet? get defaultSpreadsheet {
    final cached = Cache.instance.get<String>(cacheKey);
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
    return Column(children: [
      Row(children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => widget.onExecute(spreadsheet),
            child: Text(label),
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
    super.initState();
    spreadsheet = widget.defaultSpreadsheet;
  }

  Future<void> showActions() async {
    final selected = await showCircularBottomSheet<_ActionTypes>(
      context,
      actions: <BottomSheetAction<_ActionTypes>>[
        const BottomSheetAction(
          title: Text('選擇試算表'),
          leading: Icon(Icons.list_alt_sharp),
          returnValue: _ActionTypes.request,
        ),
        if (!widget.forceExist)
          const BottomSheetAction(
            title: Text('建立試算表'),
            leading: Icon(Icons.add_box_outlined),
            returnValue: _ActionTypes.create,
          ),
      ],
    );

    if (selected == _ActionTypes.request) {
      await request();
    } else if (selected == _ActionTypes.create) {
      await update(null);
      if (mounted) {
        showSnackBar(context, S.actSuccess);
      }
    }
  }

  Future<void> request() async {
    _notify('_start');

    final result = await showSnackbarWhenFailed(
      _requestByDialog(),
      context,
      'gs_select_failed',
    );
    if (result != null) {
      await update(result);
      if (mounted) {
        showSnackBar(context, S.actSuccess);
      }
    }

    _notify('_finish');
  }

  Future<void> update(GoogleSpreadsheet? other) async {
    Log.ger('change start', 'gs_export', other?.toString());
    setState(() => spreadsheet = other);
    await widget.onUpdate?.call(other);

    if (other == null) {
      Log.ger('change clear', 'gs_export');
      return;
    }

    await Cache.instance.set<String>(widget.cacheKey, other.toString());
  }

  void _notify(String signal) {
    if (widget.notifier != null) {
      widget.notifier!.value = signal;
    }
  }

  Future<GoogleSpreadsheet?> _requestByDialog() async {
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
            labelText: S.exporterGSSpreadsheetLabel,
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

    if (id == null) return null;

    final result = await widget.exporter.getSpreadsheet(id);
    if (result == null) {
      if (context.mounted) {
        showSnackBar(context, '找不到該表單，是否沒開放權限讀取？');
      }
    }

    return result;
  }
}

String? _spreadsheetValidator(String? text) {
  if (text == null || text.isEmpty) return '不能為空';

  if (!_sheetUrlRegex.hasMatch(text) || !_sheetIdRegex.hasMatch(text)) {
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

enum _ActionTypes { request, create }
