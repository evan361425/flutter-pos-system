import 'package:flutter/material.dart';
import 'package:possystem/components/loading_wrapper.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/google_sheet_formatter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/previews/previewer_screen.dart';

const _exporterIdCacheKey = 'exporter_google_sheet_id';
const _exporterNameCacheKey = 'exporter_google_sheet_name';
const _importerIdCacheKey = 'importer_google_sheet_id';
const _importerNameCacheKey = 'importer_google_sheet_name';
const _errorCodeRefresh = 'google_sheet_refresh_failed';
const _errorCodeImport = 'google_sheet_import_failed';
const _errorCodeExport = 'google_sheet_export_failed';
const _errorCodePick = 'google_sheet_pick_failed';

class GoogleSheetScreen extends StatefulWidget {
  final GoogleSheetExporter? exporter;

  const GoogleSheetScreen({Key? key, this.exporter}) : super(key: key);

  @override
  State<GoogleSheetScreen> createState() => GoogleSheetScreenState();
}

class GoogleSheetScreenState extends State<GoogleSheetScreen> {
  final loading = GlobalKey<LoadingWrapperState>();

  late final GoogleSheetExporter exporter;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: LoadingWrapper(
        key: loading,
        child: Scaffold(
          appBar: AppBar(
            title: Text(S.exporterGSTitle),
            leading: const PopButton(),
            bottom: TabBar(
              tabs: [
                Tab(text: S.btnExport),
                Tab(text: S.btnImport),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _ExporterScreen(
                exporter: exporter,
                startLoading: _startLoading,
                finishLoading: _finishLoading,
                setProgressStatus: _setProgressStatus,
              ),
              _ImporterScreen(
                exporter: exporter,
                startLoading: _startLoading,
                finishLoading: _finishLoading,
                setProgressStatus: _setProgressStatus,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLoading() {
    loading.currentState?.startLoading();
  }

  void _finishLoading() {
    loading.currentState?.finishLoading();
  }

  void _setProgressStatus(String status) {
    loading.currentState?.setStatus(status);
  }

  @override
  void initState() {
    exporter = widget.exporter ?? GoogleSheetExporter();
    super.initState();
  }

  @override
  void dispose() {
    loading.currentState?.dispose();
    super.dispose();
  }
}

class _ExporterScreen extends StatefulWidget {
  final void Function() startLoading;

  final void Function() finishLoading;

  final void Function(String status) setProgressStatus;

  final GoogleSheetExporter exporter;

  const _ExporterScreen({
    Key? key,
    required this.exporter,
    required this.startLoading,
    required this.finishLoading,
    required this.setProgressStatus,
  }) : super(key: key);

  @override
  State<_ExporterScreen> createState() => _ExporterScreenState();
}

class _ExporterScreenState extends State<_ExporterScreen> {
  final sheetSelector = GlobalKey<_SpreadsheetPickerState>();

  final sheets = <GoogleSheetAble, GlobalKey<_SheetNamerState>>{
    GoogleSheetAble.menu: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.stock: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.quantities: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.replenisher: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.customer: GlobalKey<_SheetNamerState>(),
  };

  late final FocusNode focusNode;

  GoogleSpreadsheet? spreadsheet;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _SpreadsheetPicker(
          id: 'gs_export.exporter_spreadsheet',
          key: sheetSelector,
          exporter: widget.exporter,
          spreadsheet: spreadsheet,
          helperText: S.exporterGSSpreadsheetHelper,
          onSheetChanged: onSheetChanged,
          onSelectStart: widget.startLoading,
          onSelectEnd: widget.finishLoading,
        ),
        ElevatedButton.icon(
          onPressed: exportData,
          focusNode: focusNode,
          label: Text(S.btnExport),
          icon: const Icon(Icons.upload_file_outlined),
        ),
        const Divider(),
        for (final entry in sheets.entries)
          Row(children: [
            Expanded(
              child: _SheetNamer(
                key: entry.value,
                label: entry.key.name,
                sheets: spreadsheet?.sheets,
                initialValue: _getDefault(entry.key.name),
                initialChecked:
                    GoogleSheetFormatter.getTarget(entry.key).isNotEmpty,
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
      ]),
    );
  }

  Future<void> onSheetChanged(GoogleSpreadsheet? newSpreadsheet) async {
    debug(newSpreadsheet.toString(), 'google_sheet_export_changed');
    spreadsheet = newSpreadsheet;
    for (var sheet in sheets.values) {
      sheet.currentState?.setHints(spreadsheet?.sheets);
    }

    if (spreadsheet == null) return;

    await Cache.instance.set<String>(_exporterIdCacheKey, spreadsheet!.id);
    await Cache.instance.set<String>(_exporterNameCacheKey, spreadsheet!.name);
  }

  void previewTarget(GoogleSheetAble able) {
    const formatter = GoogleSheetFormatter();
    final target = GoogleSheetFormatter.getTarget(able);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SheetPreviewer(
          source: _SheetPreviewerDataTableSource(
            target.getFormattedItems(formatter),
          ),
          header: target.getFormattedHead(formatter),
          title: S.exporterGSDefaultSheetName(able.name),
        ),
      ),
    );
  }

  Future<void> exportData() async {
    // avoid showing keyboard
    focusNode.requestFocus();

    final usedSheets = sheets.entries.where((entry) =>
        entry.value.currentState?.checked == true &&
        entry.value.currentState?.name != null);
    final names = {
      for (var sheet in usedSheets) sheet.key: sheet.value.currentState!.name!,
    };

    if (names.isEmpty) {
      return;
    } else if (names.values.toSet().length != names.length) {
      showErrorSnackbar(context, S.exporterGSErrors('sheet_repeat'));
      return;
    }

    widget.startLoading();

    await showSnackbarWhenFailed(
      _exportData(names),
      context,
      _errorCodeExport,
    );

    widget.finishLoading();
  }

  Future<void> _exportData(Map<GoogleSheetAble, String> names) async {
    final prepared = await _getSpreadsheet(names);
    if (prepared == null) return;

    debug(spreadsheet!.id, 'google_sheet_export_ready');
    const formatter = GoogleSheetFormatter();
    for (final entry in prepared.entries) {
      final target = GoogleSheetFormatter.getTarget(entry.key);
      final label = entry.key.name;
      widget.setProgressStatus(S.exporterGSProgressStatus('update_$label'));
      await _setDefault(label, entry.value.title);
      await widget.exporter.updateSheet(
        spreadsheet!.id,
        entry.value.id,
        target.getFormattedItems(formatter),
        target.getFormattedHead(formatter),
      );
    }
    showSuccessSnackbar(context, S.actSuccess);
  }

  Future<GoogleSpreadsheet?> _createSpreadsheet(List<String> names) async {
    widget.setProgressStatus(S.exporterGSProgressStatus('add_spreadsheet'));

    return widget.exporter.addSpreadsheet(
      S.exporterGSDefaultSpreadsheetName,
      names,
    );
  }

  Future<bool> _addSheets(List<String> requiredSheets) async {
    widget.setProgressStatus(S.exporterGSProgressStatus('add_sheets'));
    final exist = spreadsheet!.sheets.map((e) => e.title).toSet();
    final missing = requiredSheets.toSet().difference(exist);

    if (missing.isEmpty) {
      return true;
    }

    final newSheets = await widget.exporter.addSheets(
      spreadsheet!.id,
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
  Future<Map<GoogleSheetAble, GoogleSheetProperties>?> _getSpreadsheet(
    Map<GoogleSheetAble, String> requireSheets,
  ) async {
    widget.setProgressStatus('驗證身份中');
    await widget.exporter.auth();

    final names = requireSheets.values.toList();
    spreadsheet ??= await _createSpreadsheet(names);
    if (spreadsheet == null) {
      showErrorSnackbar(context, S.exporterGSErrors('spreadsheet'));
      return null;
    } else {
      final sheets = await widget.exporter.getSheets(spreadsheet!.id);
      spreadsheet!.sheets.addAll(sheets);
      final success = await _addSheets(names);
      if (!success) {
        showErrorSnackbar(context, S.exporterGSErrors('sheet'));
        return null;
      }
    }

    return {
      for (var e in requireSheets.entries)
        e.key: GoogleSheetProperties(
          spreadsheet!.sheets.firstWhere((sheet) => sheet.title == e.value).id,
          e.value,
        )
    };
  }

  String _getDefault(String label) {
    return Cache.instance.get<String>('$_exporterNameCacheKey.$label') ??
        S.exporterGSDefaultSheetName(label);
  }

  Future<void> _setDefault(String label, String title) async {
    final key = '$_exporterNameCacheKey.$label';
    if (title != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, title);
    }
  }

  @override
  void initState() {
    focusNode = FocusNode();
    final id = Cache.instance.get<String>(_exporterIdCacheKey);
    final name = Cache.instance.get<String>(_exporterNameCacheKey);
    if (id != null && name != null) {
      spreadsheet = GoogleSpreadsheet(
        id: id,
        name: name,
        sheets: [],
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    sheetSelector.currentState?.dispose();
    for (var sheet in sheets.values) {
      sheet.currentState?.dispose();
    }
    super.dispose();
  }
}

class _ImporterScreen extends StatefulWidget {
  final void Function() startLoading;

  final void Function() finishLoading;

  final void Function(String status) setProgressStatus;

  final GoogleSheetExporter exporter;

  const _ImporterScreen({
    Key? key,
    required this.exporter,
    required this.startLoading,
    required this.finishLoading,
    required this.setProgressStatus,
  }) : super(key: key);

  @override
  State<_ImporterScreen> createState() => _ImporterScreenState();
}

class _ImporterScreenState extends State<_ImporterScreen> {
  final loading = GlobalKey<LoadingWrapperState>();
  final sheetSelector = GlobalKey<_SpreadsheetPickerState>();

  final sheets = <GoogleSheetAble, GlobalKey<_SheetSelectorState>>{
    GoogleSheetAble.menu: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.stock: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.quantities: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.replenisher: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.customer: GlobalKey<_SheetSelectorState>(),
  };

  GoogleSpreadsheet? spreadsheet;

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      key: loading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _SpreadsheetPicker(
            id: 'gs_export.importer_spreadsheet',
            key: sheetSelector,
            exporter: widget.exporter,
            spreadsheet: spreadsheet,
            allowEmpty: false,
            helperText: S.btnImporterRefreshHelp,
            onSheetChanged: onSheetChanged,
            onSelectStart: widget.startLoading,
            onSelectEnd: widget.finishLoading,
          ),
          const SizedBox(height: 4.0),
          ElevatedButton.icon(
            onPressed: refreshSheet,
            label: Text(S.btnImporterRefresh),
            icon: const Icon(Icons.refresh_outlined),
          ),
          const Divider(),
          for (final entry in sheets.entries)
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: _SheetSelector(
                  key: entry.value,
                  label: entry.key.name,
                  defaultValue: _getDefault(entry.key.name),
                ),
              ),
              const SizedBox(width: 8.0),
              OutlinedButton.icon(
                onPressed: () => importData(entry.key),
                label: const Text('匯入'),
                icon: const Icon(Icons.download_for_offline_outlined),
              ),
            ]),
        ]),
      ),
    );
  }

  Future<void> onSheetChanged(GoogleSpreadsheet? newSpreadsheet) async {
    debug(newSpreadsheet.toString(), 'google_sheet_import_changed');
    spreadsheet = newSpreadsheet;
    for (var sheet in sheets.values) {
      sheet.currentState?.setSheets(spreadsheet!.sheets);
    }

    await Cache.instance.set<String>(_importerIdCacheKey, spreadsheet!.id);
    await Cache.instance.set<String>(_importerNameCacheKey, spreadsheet!.name);
  }

  Future<void> refreshSheet() async {
    if (spreadsheet == null) {
      showInfoSnackbar(context, S.importerGSError('empty_spreadsheet'));
      return;
    }

    loading.currentState?.startLoading();

    await showSnackbarWhenFailed(
      _refreshSheet(spreadsheet!),
      context,
      _errorCodeRefresh,
    );

    loading.currentState?.finishLoading();
  }

  Future<void> importData(GoogleSheetAble type) async {
    if (spreadsheet == null) {
      showErrorSnackbar(context, S.importerGSError('empty_spreadsheet'));
      return;
    } else if (sheets[type]?.currentState?.selected == null) {
      showErrorSnackbar(context, S.importerGSError('empty_sheet'));
      return;
    }

    widget.startLoading();

    await showSnackbarWhenFailed(
      _importData(type, sheets[type]!.currentState!.selected!),
      context,
      _errorCodeImport,
    );

    widget.finishLoading();
  }

  Future<void> _refreshSheet(GoogleSpreadsheet spreadsheet) async {
    final refreshedSheets = await widget.exporter.getSheets(
      spreadsheet.id,
    );

    for (var sheet in sheets.values) {
      sheet.currentState?.setSheets(refreshedSheets);
    }
  }

  Future<void> _importData(
    GoogleSheetAble type,
    GoogleSheetProperties sheet,
  ) async {
    debug(sheet.title, 'google_sheet_import_ready');
    final source = await _getSheetData(type, sheet);
    if (source == null) return;

    await _setDefault(type.name, sheet);

    debug(source.length.toString(), 'google_sheet_import_length');
    final allowPreviewFormed = await _previewSheetData(type, source);
    if (allowPreviewFormed != true) return;

    final allowSave = await _previewParsedData(type, source);
    final target = GoogleSheetFormatter.getTarget(type);

    if (allowSave == true) {
      await target.commitStaged();
      showSuccessSnackbar(context, S.actSuccess);
    } else {
      target.abortStaged();
    }
  }

  Future<bool?> _previewSheetData(
    GoogleSheetAble type,
    List<List<Object?>> source,
  ) async {
    const formatter = GoogleSheetFormatter();
    final target = GoogleSheetFormatter.getTarget(type);
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _SheetPreviewer(
          source: _SheetPreviewerDataTableSource(source),
          header: target.getFormattedHead(formatter),
          title: S.exporterGSDefaultSheetName(type.name),
          actions: [
            AppbarTextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(S.importPreviewerTitle),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  Future<bool?> _previewParsedData(
    GoogleSheetAble type,
    List<List<Object?>> source,
  ) {
    const formatter = GoogleSheetFormatter();
    final target = GoogleSheetFormatter.getTarget(type);
    final formatted = formatter.format(target, source);
    return PreviewerScreen.navByTarget(
      context,
      GoogleSheetFormatter.toFormattable(type),
      formatted,
    );
  }

  Future<List<List<Object?>>?> _getSheetData(
    GoogleSheetAble type,
    GoogleSheetProperties sheet,
  ) async {
    widget.setProgressStatus('驗證身份中');
    await widget.exporter.auth();

    const formatter = GoogleSheetFormatter();
    final target = GoogleSheetFormatter.getTarget(type);
    final neededColumns = target.getFormattedHead(formatter).length;

    final sheetData = await widget.exporter.getSheetData(
      spreadsheet!.id,
      sheet.title,
      neededColumns: neededColumns,
    );

    // remove header
    final data = sheetData?.sublist(1);
    if (data?.isEmpty != false) {
      showInfoSnackbar(context, S.importerGSError('empty_data'));
      return null;
    }

    return data;
  }

  Future<void> _setDefault(String label, GoogleSheetProperties sheet) async {
    final key = '$_importerNameCacheKey.$label';
    if (sheet.toCacheValue() != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, sheet.toCacheValue());
    }
  }

  GoogleSheetProperties? _getDefault(String label) {
    final nameId = Cache.instance.get<String>('$_importerNameCacheKey.$label');

    return GoogleSheetProperties.fromCacheValue(nameId);
  }

  @override
  void initState() {
    final id = Cache.instance.get<String>(_importerIdCacheKey);
    final name = Cache.instance.get<String>(_importerNameCacheKey);
    if (id != null && name != null) {
      spreadsheet = GoogleSpreadsheet(
        id: id,
        name: name,
        sheets: [],
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    loading.currentState?.dispose();
    sheetSelector.currentState?.dispose();
    for (var sheet in sheets.values) {
      sheet.currentState?.dispose();
    }
    super.dispose();
  }
}

class _SpreadsheetPicker extends StatefulWidget {
  final String id;

  final GoogleSheetExporter exporter;

  final Future<void> Function(GoogleSpreadsheet?) onSheetChanged;

  final void Function() onSelectStart;

  final void Function() onSelectEnd;

  final GoogleSpreadsheet? spreadsheet;

  final bool allowEmpty;

  final String? helperText;

  const _SpreadsheetPicker({
    Key? key,
    this.spreadsheet,
    required this.id,
    required this.exporter,
    required this.onSheetChanged,
    required this.onSelectStart,
    required this.onSelectEnd,
    this.allowEmpty = true,
    this.helperText,
  }) : super(key: key);

  @override
  State<_SpreadsheetPicker> createState() => _SpreadsheetPickerState();
}

class _SpreadsheetPickerState extends State<_SpreadsheetPicker> {
  late TextEditingController _controller;

  GoogleSpreadsheet? spreadsheet;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: Key(widget.id),
      controller: _controller,
      readOnly: true,
      onTap: pickSheet,
      decoration: InputDecoration(
        labelText: S.exporterGSSpreadsheetLabel,
        hintText: S.exporterGSSpreadsheetHint,
        helperText: widget.helperText,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffix: widget.allowEmpty
            ? GestureDetector(
                onTap: () => setSheet(null),
                child: const Icon(KIcons.clear, size: 16.0),
              )
            : null,
      ),
    );
  }

  Future<void> pickSheet() async {
    try {
      widget.onSelectStart();
      final result = await widget.exporter.pickSheet();
      if (result != null) {
        setSheet(result);
      }
    } catch (e) {
      if (e is GoogleSheetError) {
        showErrorSnackbar(context, S.exporterGSErrors(e.code));
      } else {
        showErrorSnackbar(context, S.actError);
        error(e.toString(), _errorCodePick);
      }
    } finally {
      widget.onSelectEnd();
    }
  }

  Future<void> setSheet(GoogleSpreadsheet? newSheet) {
    _controller.text = newSheet?.name ?? '';
    spreadsheet = newSheet;
    return widget.onSheetChanged(newSheet);
  }

  @override
  void initState() {
    spreadsheet = widget.spreadsheet;
    _controller = TextEditingController(text: spreadsheet?.name);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SheetNamer extends StatefulWidget {
  final String initialValue;

  final String label;

  final bool initialChecked;

  final List<GoogleSheetProperties>? sheets;

  const _SheetNamer({
    Key? key,
    required this.initialValue,
    required this.label,
    required this.initialChecked,
    this.sheets,
  }) : super(key: key);

  @override
  State<_SheetNamer> createState() => _SheetNamerState();
}

class _SheetNamerState extends State<_SheetNamer> {
  Iterable<String>? autofillHints;

  late TextEditingController _controller;

  late bool checked;

  String? get name => _controller.text.isEmpty ? null : _controller.text;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: Key('gs_export.${widget.label}.sheet_namer'),
      controller: _controller,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        prefix: SizedBox(
          height: 14,
          child: Checkbox(
            key: Key('gs_export.${widget.label}.checkbox'),
            value: checked,
            visualDensity: VisualDensity.compact,
            splashRadius: 0,
            onChanged: (newValue) => setState(() => checked = newValue!),
          ),
        ),
        labelText: S.exporterGSSheetLabel(
          S.exporterGSDefaultSheetName(widget.label),
        ),
        hintText: widget.initialValue,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  void setHints(List<GoogleSheetProperties>? sheets) {
    setState(() => _setHints(sheets));
  }

  void _setHints(List<GoogleSheetProperties>? sheets) {
    autofillHints = sheets?.map((e) => e.title);
  }

  @override
  void initState() {
    checked = widget.initialChecked;
    _controller = TextEditingController(text: widget.initialValue);
    _setHints(widget.sheets);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SheetSelector extends StatefulWidget {
  final GoogleSheetProperties? defaultValue;

  final String label;

  const _SheetSelector({
    Key? key,
    this.defaultValue,
    required this.label,
  }) : super(key: key);

  @override
  State<_SheetSelector> createState() => _SheetSelectorState();
}

class _SheetSelectorState extends State<_SheetSelector> {
  late List<GoogleSheetProperties> sheets;

  GoogleSheetProperties? selected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<GoogleSheetProperties>(
      key: Key('gs_export.${widget.label}.sheet_selector'),
      value: selected,
      decoration: InputDecoration(
        label: Text(S.exporterGSSheetLabel(
          S.exporterGSDefaultSheetName(widget.label),
        )),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      onChanged: (newSelected) => setState(() => selected = newSelected),
      items: [
        for (var sheet in sheets)
          DropdownMenuItem<GoogleSheetProperties>(
            value: sheet,
            child: Text(sheet.title),
          ),
      ],
    );
  }

  setSheets(List<GoogleSheetProperties> newSheets) {
    setState(() {
      if (!newSheets.contains(selected)) {
        selected = null;
      }
      sheets = newSheets;
    });
  }

  @override
  void initState() {
    selected = widget.defaultValue;
    sheets = selected != null ? [selected!] : const [];
    super.initState();
  }
}

class _SheetPreviewer extends StatelessWidget {
  final _SheetPreviewerDataTableSource source;

  final String title;

  final List<GoogleSheetCellData> header;

  final List<Widget>? actions;

  const _SheetPreviewer({
    Key? key,
    required this.source,
    required this.title,
    required this.header,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: const PopButton(),
        actions: actions,
      ),
      body: SingleChildScrollView(
        child: PaginatedDataTable(
          columns: [
            for (final cell in header)
              DataColumn(
                label: cell.note == null
                    ? Text(
                        cell.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : Row(children: [
                        Text(
                          cell.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.info_outline),
                      ]),
                tooltip: cell.note,
              ),
          ],
          source: source,
          showCheckboxColumn: false,
        ),
      ),
    );
  }
}

class _SheetPreviewerDataTableSource extends DataTableSource {
  final List<List<Object?>> data;

  _SheetPreviewerDataTableSource(this.data);

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      for (final item in data[index])
        DataCell(Tooltip(
          message: item.toString(),
          child: Text(item.toString()),
        )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
