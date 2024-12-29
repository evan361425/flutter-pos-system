import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/style/buttons.dart';
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

  /// The key to cache the selected spreadsheet
  final String cacheKey;

  /// The key to cache the selected spreadsheet when the [cacheKey] is not found
  ///
  /// For example import and export use different cache key but they want to
  /// share the same spreadsheet when the user only select one.
  final String fallbackCacheKey;

  /// The default name of the spreadsheet
  final String defaultName;

  /// The text of the button when the spreadsheet is exist
  final String existLabel;

  /// The text of the button when the spreadsheet is not set
  final String emptyLabel;

  /// The hint text when the spreadsheet is exist
  final String Function(String) existHint;

  /// The hint text when the spreadsheet is not set
  final String emptyHint;

  /// Spreadsheet has been updated(clear or changed), should update the UI
  final Future<void> Function(GoogleSpreadsheet? spreadsheet)? onUpdated;

  /// Spreadsheet has been changed, should update the UI
  final Future<void> Function(GoogleSpreadsheet spreadsheet)? onChosen;

  /// Spreadsheet has been prepared(sheet has been created), should start exporting
  final Future<void> Function(
    GoogleSpreadsheet spreadsheet,
    Map<SheetType, GoogleSheetProperties> sheets,
  )? onPrepared;

  /// The title of the sheets when the spreadsheet is created.
  ///
  /// This means the user can create a spreadsheet and prepare the sheets at the same time.
  final Map<SheetType, String> Function()? requiredSheetTitles;

  const SpreadsheetSelector({
    super.key,
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
  });

  @override
  State<SpreadsheetSelector> createState() => SpreadsheetSelectorState();

  GoogleSpreadsheet? get defaultSpreadsheet {
    final cached = Cache.instance.get<String>(cacheKey) ?? Cache.instance.get<String>(fallbackCacheKey);
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

  String get hint => isExist ? widget.existHint(spreadsheet!.name) : widget.emptyHint;

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
        trailing: EntryMoreButton(onPressed: showActions),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    spreadsheet = widget.defaultSpreadsheet;
  }

  void showActions(BuildContext context) async {
    final selected = await showCircularBottomSheet<_ActionTypes>(
      context,
      actions: <BottomSheetAction<_ActionTypes>>[
        BottomSheetAction(
          title: Text(S.transitGSSpreadsheetActionSelect),
          leading: const Icon(Icons.file_open_outlined),
          returnValue: _ActionTypes.choose,
        ),
        if (widget.requiredSheetTitles != null)
          BottomSheetAction(
            title: Text(S.transitGSSpreadsheetActionClear),
            leading: const Icon(Icons.cleaning_services_outlined),
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

  /// Execute the action when the button is clicked
  void execute() async {
    await showSnackbarWhenFutureError(
      _execute(),
      '${widget.cacheKey}_failed',
      context: context,
    );

    _notify('_finish');
  }

  /// Choose a spreadsheet
  Future<void> choose() async {
    _notify('_start');

    await showSnackbarWhenFutureError(
      _choose(),
      'gs_select_request_failed',
      context: context,
    );

    _notify('_finish');
  }

  /// Clear the selected spreadsheet
  Future<void> clear() async {
    await _update(null);

    if (mounted) {
      showSnackBar(S.actSuccess, context: context);
    }
  }

  void _notify(String signal) {
    if (widget.notifier != null) {
      widget.notifier!.value = signal;
    }
  }

  Future<void> _execute() async {
    final requiredSheetTitles = widget.requiredSheetTitles;
    // If the required sheets are not set, notify the user to choose a spreadsheet
    if (requiredSheetTitles == null) {
      _notify('_start');
      if (!isExist) {
        await _choose();
      }

      // It is successful from previous action or already have the spreadsheet
      if (isExist) {
        await widget.onChosen?.call(spreadsheet!);
      }
      return;
    }

    final confirmed = await ConfirmDialog.show(
      context,
      title: '$label？',
      content: S.transitGSSpreadsheetConfirm(hint),
    );

    if (confirmed) {
      _notify('_start');
      // create sheets and execute callback
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
            helperText: S.transitGSSpreadsheetSelectionHint(spreadsheet?.name.toString() ?? '_'),
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
        showSnackBar(S.actSuccess, context: context);
      }
    } else if (mounted) {
      showMoreInfoSnackBar(
        S.transitGSErrorImportNotFoundSpreadsheet,
        Text(S.transitGSErrorImportNotFoundHelper),
        context: context,
      );
    }
  }

  Future<void> _update(GoogleSpreadsheet? other) async {
    Log.ger('gs_select', {'spreadsheet': other?.id});
    if (mounted) {
      setState(() => spreadsheet = other);
    }
    await widget.onUpdated?.call(other);

    if (other != null) {
      await Cache.instance.set<String>(widget.cacheKey, other.toString());
    }
  }

  /// Prepare the sheets in the spreadsheet.
  ///
  /// If the spreadsheet is not exist, create it and create all the sheets.
  /// If the spreadsheet is exist, prepare the sheets.
  Future<Map<SheetType, GoogleSheetProperties>?> _prepare(
    GoogleSpreadsheet? ss,
    Map<SheetType, String> sheets,
  ) async {
    if (sheets.isEmpty) {
      showSnackBar(S.transitGSErrorSheetEmpty, context: context);
      return null;
    }

    if (sheets.values.toSet().length != sheets.length) {
      showSnackBar(S.transitGSErrorSheetRepeat, context: context);
      return null;
    }

    _notify(S.transitGSProgressStatusVerifyUser);

    await widget.exporter.auth();

    final names = sheets.values.toList();
    if (ss == null) {
      _notify(S.transitGSProgressStatusAddSpreadsheet);

      final other = await widget.exporter.addSpreadsheet(
        widget.defaultName,
        names,
      );
      if (other == null) {
        if (mounted) {
          showMoreInfoSnackBar(
            S.transitGSErrorCreateSpreadsheet,
            Text(S.transitGSErrorCreateSpreadsheetHelper),
            context: context,
          );
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
          showMoreInfoSnackBar(
            S.transitGSErrorCreateSheet,
            Text(S.transitGSErrorCreateSheetHelper),
            context: context,
          );
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

  /// Fulfill the sheets in the spreadsheet
  Future<bool> _fulfillSheets(GoogleSpreadsheet ss, List<String> names) async {
    final exist = ss.sheets.map((e) => e.title).toSet();
    final missing = names.toSet().difference(exist);
    if (missing.isEmpty) {
      return true;
    }

    _notify(S.transitGSProgressStatusAddSheets);
    final added = await widget.exporter.addSheets(ss, missing.toList());
    if (added != null) {
      ss.sheets.addAll(added);
      return true;
    }

    return false;
  }
}

String? _spreadsheetValidator(String? text) {
  if (text == null || text.isEmpty) return S.transitGSErrorSpreadsheetIdEmpty;

  if (!_sheetUrlRegex.hasMatch(text) && !_sheetIdRegex.hasMatch(text)) {
    return S.transitGSErrorSpreadsheetIdInvalid;
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
  orderDetailsAttr,
  orderDetailsProduct,
  orderDetailsIngredient,
}
