import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/google_sheet_exporter.dart';

final _sheetUrlRegex = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]{15,})/');
final _sheetIdRegex = RegExp(r'^([a-zA-Z0-9-_]{15,})$');
const _sheetTutorial =
    "https://raw.githubusercontent.com/evan361425/flutter-pos-system/master/assets/web/tutorial-gs-copy-url.gif";

const exportCacheKey = 'importer_google_sheet';
const importCacheKey = 'exporter_google_sheet';

/// Prepare the spreadsheet for exporting.
///
/// Step A
/// If the [spreadsheet] has empty id, create a new spreadsheet with
/// [defaultName] and [sheets].
///
/// Step B
/// If the [spreadsheet] has id, check if the [sheets] are all in the
/// spreadsheet, and if not, add the missing sheets to the spreadsheet.
Future<GoogleSpreadsheet?> prepareSpreadsheet({
  required BuildContext context,
  required GoogleSheetExporter exporter,
  required ValueNotifier<String> stateNotifier,
  required String defaultName,
  required String cacheKey,
  required List<String> sheets,
  required GoogleSpreadsheet spreadsheet,
}) async {
  // Step A, create a new spreadsheet
  if (spreadsheet.id == '') {
    stateNotifier.value = S.transitGSProgressStatusAddSpreadsheet;

    final ss = await exporter.addSpreadsheet(defaultName, sheets);
    Log.out('create spreadsheet: ${ss?.name}', 'gs_export');
    if (ss == null) {
      if (context.mounted) {
        showMoreInfoSnackBar(
          S.transitGSErrorCreateSpreadsheet,
          Text(S.transitGSErrorCreateSpreadsheetHelper),
          context: context,
        );
      }
      return null;
    }

    await Cache.instance.set<String>(cacheKey, ss.toString());
    return ss;
  }

  // Step B, add missing sheets
  //
  // 1. Get all sheets from the spreadsheet
  // 2. Check if all required sheets are in the spreadsheet
  // 3. If not, add the missing sheets
  final wanted = sheets.toSet();
  if (!spreadsheet.containsAll(wanted)) {
    final requested = await exporter.getSheets(spreadsheet);
    spreadsheet.merge(requested);
  }

  final exist = spreadsheet.sheets.map((e) => e.title).toSet();
  final missing = wanted.difference(exist);
  if (missing.isEmpty) {
    return spreadsheet;
  }

  stateNotifier.value = S.transitGSProgressStatusAddSheets;
  final added = await exporter.addSheets(spreadsheet, missing.toList());
  Log.out('add ${added?.length} sheets to spreadsheet: ${spreadsheet.name}', 'gs_export');
  if (added == null) {
    if (context.mounted) {
      showMoreInfoSnackBar(
        S.transitGSErrorCreateSheet,
        Text(S.transitGSErrorCreateSheetHelper),
        context: context,
      );
    }
    return null;
  }

  spreadsheet.sheets.addAll(added);
  return spreadsheet;
}

class SpreadsheetDialog extends StatefulWidget {
  final GoogleSheetExporter exporter;
  final String cacheKey;
  final String? fallbackCacheKey;

  const SpreadsheetDialog({
    super.key,
    required this.exporter,
    required this.cacheKey,
    this.fallbackCacheKey,
  });

  static Future<GoogleSpreadsheet?> show(
    BuildContext context, {
    required GoogleSheetExporter exporter,
    required String cacheKey,
    String? fallbackCacheKey,
  }) {
    return showAdaptiveDialog<GoogleSpreadsheet>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => SpreadsheetDialog(
        exporter: exporter,
        cacheKey: cacheKey,
        fallbackCacheKey: fallbackCacheKey,
      ),
    );
  }

  @override
  State<SpreadsheetDialog> createState() => _SpreadsheetDialogState();
}

class _SpreadsheetDialogState extends State<SpreadsheetDialog> {
  final form = GlobalKey<FormState>();

  /// Toggler for the finding spreadsheet tutorial image.
  bool showTutorial = false;

  /// Whether the user wants to create a new spreadsheet.
  late bool createNew;

  /// If not creating a new spreadsheet, the id of the selected spreadsheet.
  GoogleSpreadsheet? spreadsheet;

  late TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text('Select a spreadsheet'),
      content: SingleChildScrollView(
        child: Column(children: [
          CheckboxListTile.adaptive(
            dense: true,
            value: createNew,
            title: const Text('Create new spreadsheet'),
            onChanged: (v) => setState(() => createNew = v!),
          ),
          CheckboxListTile.adaptive(
            dense: true,
            value: !createNew,
            title: const Text('Select existing spreadsheet'),
            onChanged: (v) => setState(() => createNew = !v!),
          ),
          if (!createNew) ...[
            const Divider(),
            _buildTextField(),
          ],
          if (showTutorial) ...[
            const SizedBox(height: 16.0),
            _buildTutorialImage(),
          ],
        ]),
      ),
      actions: [
        PopButton(title: MaterialLocalizations.of(context).cancelButtonLabel),
        TextButton(
          onPressed: _export,
          child: Text(S.transitExportBtn),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return Form(
      key: form,
      child: TextFormField(
        key: const Key('transit.spreadsheet_dialog'),
        autocorrect: false,
        controller: textController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        validator: _spreadsheetValidator,
        onSaved: _submit,
        decoration: InputDecoration(
          labelText: S.transitGSSpreadsheetLabel,
          // TODO: 要說明會覆蓋 sheet
          helperText: S.transitGSSpreadsheetSelectionHint(spreadsheet?.name ?? '_'),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          errorMaxLines: 5,
          suffixIcon: IconButton(
            icon: Icon(showTutorial ? Icons.help : Icons.help_outline),
            onPressed: () => setState(() => showTutorial = !showTutorial),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialImage() {
    return CachedNetworkImage(
      imageUrl: _sheetTutorial,
      progressIndicatorBuilder: (context, url, prog) => CircularProgressIndicator.adaptive(value: prog.progress),
    );
  }

  @override
  void initState() {
    final val =
        Cache.instance.get<String>(widget.cacheKey) ?? Cache.instance.get<String>(widget.fallbackCacheKey ?? '');
    if (val != null) {
      spreadsheet = GoogleSpreadsheet.fromString(val);
    }

    createNew = spreadsheet == null;
    textController = TextEditingController(text: spreadsheet?.id);
    super.initState();
  }

  void _export() {
    if (createNew) {
      Navigator.of(context).pop(GoogleSpreadsheet(id: '', name: '', sheets: []));
      return;
    }

    if (form.currentState?.validate() == true) {
      form.currentState!.save();
    }
  }

  /// [_spreadsheetValidator] has already make sure [text] is not null
  Future<void> _submit(String? text) async {
    final urlResult = _sheetUrlRegex.firstMatch(text!);

    if (urlResult != null) {
      await _setupSpreadsheet(urlResult.group(1));
    } else {
      await _setupSpreadsheet(_sheetIdRegex.firstMatch(text)?.group(0));
    }

    if (spreadsheet != null && mounted) {
      Navigator.of(context).pop(spreadsheet);
    }
  }

  Future<void> _setupSpreadsheet(String? id) async {
    if (id != null && id != spreadsheet?.id) {
      final other = await widget.exporter.getSpreadsheet(id);

      await Cache.instance.set<String>(widget.cacheKey, other.toString());
      setState(() => spreadsheet = other);
    }
  }
}

String? _spreadsheetValidator(String? text) {
  if (text == null || text.isEmpty) return S.transitGSErrorSpreadsheetIdEmpty;

  if (!_sheetUrlRegex.hasMatch(text) && !_sheetIdRegex.hasMatch(text)) {
    return S.transitGSErrorSpreadsheetIdInvalid;
  }

  return null;
}
