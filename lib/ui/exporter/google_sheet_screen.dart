import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/loading_wrapper.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/google_sheet_formatter.dart';
import 'package:possystem/helpers/laucher.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/previews/previewer_screen.dart';

const _exporterCacheKey = 'exporter_google_sheet';
const _importerCacheKey = 'importer_google_sheet';
const _errorCodeRefresh = 'gs_refresh_failed';
const _errorCodeImport = 'gs_import_failed';
const _errorCodeExport = 'gs_export_failed';
const _errorCodeSelect = 'gs_select_failed';

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
  final sheets = <GoogleSheetAble, GlobalKey<_SheetNamerState>>{
    GoogleSheetAble.menu: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.stock: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.quantities: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.replenisher: GlobalKey<_SheetNamerState>(),
    GoogleSheetAble.customer: GlobalKey<_SheetNamerState>(),
  };

  late final FocusNode focusNode;

  GoogleSpreadsheet? spreadsheet;

  bool get hasSelect => spreadsheet != null;

  String get exportLabel => hasSelect ? '匯出於指定表單' : '匯出後建立試算單';

  String get hint =>
      hasSelect ? '將匯出於「${spreadsheet?.name}」' : '你尚未選擇試算表，匯出時將建立新的';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: exportData,
              focusNode: focusNode,
              child: Text(exportLabel),
            ),
          ),
          IconButton(
            onPressed: showActions,
            icon: const Icon(Icons.more_vert_sharp),
          ),
        ]),
        Center(child: HintText(hint)),
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
      showInfoSnackbar(context, S.actSuccess);
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
    await Cache.instance.set<String>(_exporterCacheKey, value);
    if (Cache.instance.get<String>(_importerCacheKey) == null) {
      Log.ger('change success', 'gs_export');
      await Cache.instance.set(_importerCacheKey, value);
    }
  }

  Future<void> selectSheet() async {
    widget.startLoading();

    final result = await showSnackbarWhenFailed(
      _selectSpreadsheet(context, spreadsheet, widget.exporter),
      context,
      _errorCodeSelect,
    );
    if (result != null) {
      await onSheetChanged(result);
      showInfoSnackbar(context, S.actSuccess);
    }

    widget.finishLoading();
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

    Log.ger('export ready', 'gs_export', spreadsheet!.id);
    const formatter = GoogleSheetFormatter();
    for (final entry in prepared.entries) {
      final target = GoogleSheetFormatter.getTarget(entry.key);
      final label = entry.key.name;
      widget.setProgressStatus(S.exporterGSProgressStatus('update_$label'));
      await _setDefault(label, entry.value.title);
      await widget.exporter.updateSheet(
        spreadsheet!,
        entry.value,
        target.getFormattedItems(formatter),
        target.getFormattedHead(formatter),
      );
    }
    Log.ger('export finish', 'gs_export');
    showSuccessSnackbar(
      context,
      S.actSuccess,
      SnackBarAction(
        label: '開啟表單',
        onPressed: () {
          final link = spreadsheet!.toLink();
          Log.ger('export launch', 'gs_export', link);
          Launcher.launch(link).ignore();
        },
      ),
    );
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
  Future<Map<GoogleSheetAble, GoogleSheetProperties>?> _getSpreadsheet(
    Map<GoogleSheetAble, String> requireSheets,
  ) async {
    widget.setProgressStatus('驗證身份中');
    await widget.exporter.auth();

    final names = requireSheets.values.toList();
    if (!hasSelect) {
      final newSpreadsheet = await _createSpreadsheet(names);
      if (newSpreadsheet == null) {
        showErrorSnackbar(context, S.exporterGSErrors('spreadsheet'));
        return null;
      }
      await onSheetChanged(newSpreadsheet);
    } else {
      final sheets = await widget.exporter.getSheets(spreadsheet!);
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
          typeName: e.key.name,
        )
    };
  }

  String _getDefault(String label) {
    return Cache.instance.get<String>('$_exporterCacheKey.$label') ??
        S.exporterGSDefaultSheetName(label);
  }

  Future<void> _setDefault(String label, String title) async {
    final key = '$_exporterCacheKey.$label';
    if (title != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, title);
    }
  }

  @override
  void initState() {
    focusNode = FocusNode();
    final cached = Cache.instance.get<String>(_exporterCacheKey);
    if (cached != null) {
      spreadsheet = GoogleSpreadsheet.fromString(cached);
    }
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
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

  final sheets = <GoogleSheetAble, GlobalKey<_SheetSelectorState>>{
    GoogleSheetAble.menu: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.stock: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.quantities: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.replenisher: GlobalKey<_SheetSelectorState>(),
    GoogleSheetAble.customer: GlobalKey<_SheetSelectorState>(),
  };

  GoogleSpreadsheet? spreadsheet;

  bool get hasSelect => spreadsheet != null;

  String get prepareLabel => hasSelect ? '檢查所選的試算表' : '選擇試算表';

  String get hint =>
      hasSelect ? '將於「${spreadsheet?.name}」匯入' : '你尚未選擇試算表，將無法匯入';

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      key: loading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const SizedBox(height: 4.0),
          Row(children: [
            Expanded(
              child: ElevatedButton(
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
          Center(child: HintText(hint)),
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
        .set<String>(_importerCacheKey, newSpreadsheet.toString());
    Log.ger('change finish', 'gs_import');
  }

  Future<void> selectSheet() async {
    widget.startLoading();

    final result = await showSnackbarWhenFailed(
      _selectSpreadsheet(context, spreadsheet, widget.exporter),
      context,
      _errorCodeSelect,
    );
    if (result != null) {
      await changeSpreadsheet(result);
      showInfoSnackbar(context, S.actSuccess);
    }

    widget.finishLoading();
  }

  Future<void> refreshSheet() async {
    assert(hasSelect);

    widget.startLoading();

    await showSnackbarWhenFailed(
      _refreshSheet(spreadsheet!),
      context,
      _errorCodeRefresh,
    );

    widget.finishLoading();
  }

  Future<void> importData(GoogleSheetAble type) async {
    if (!hasSelect) {
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
    final refreshedSheets = await widget.exporter.getSheets(spreadsheet);

    for (var sheet in sheets.values) {
      sheet.currentState?.setSheets(refreshedSheets);
    }
    showInfoSnackbar(context, S.actSuccess);
  }

  Future<void> _importData(
    GoogleSheetAble type,
    GoogleSheetProperties sheet,
  ) async {
    Log.ger('ready', 'gs_import', sheet.title);
    final source = await _getSheetData(type, sheet);
    if (source == null) return;

    await _setDefault(type.name, sheet);

    Log.ger('received', 'gs_import', source.length.toString());
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
      spreadsheet!,
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
    final key = '$_importerCacheKey.$label';
    if (sheet.toCacheValue() != Cache.instance.get<String>(key)) {
      await Cache.instance.set<String>(key, sheet.toCacheValue());
    }
  }

  GoogleSheetProperties? _getDefault(String label) {
    final nameId = Cache.instance.get<String>('$_importerCacheKey.$label');

    return GoogleSheetProperties.fromCacheValue(nameId);
  }

  @override
  void initState() {
    final value = Cache.instance.get<String>(_importerCacheKey);
    if (value != null) {
      spreadsheet = GoogleSpreadsheet.fromString(value);
    }
    super.initState();
  }

  @override
  void dispose() {
    loading.currentState?.dispose();
    for (var sheet in sheets.values) {
      sheet.currentState?.dispose();
    }
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

enum _ActionTypes { select, clear }

Future<GoogleSpreadsheet?> _selectSpreadsheet(
  BuildContext context,
  GoogleSpreadsheet? origin,
  GoogleSheetExporter exporter,
) async {
  const idRegex = r'^([a-zA-Z0-9-_]{15,})$';
  const urlRegex = r'/spreadsheets/d/([a-zA-Z0-9-_]{15,})/';

  String? validator(String? text) {
    if (text == null || text.isEmpty) return '不能為空';

    if (!RegExp(urlRegex).hasMatch(text)) {
      if (!RegExp(idRegex).hasMatch(text)) {
        return '不合法的文字，必須包含：\n'
            '/spreadsheets/d/<ID>/\n'
            '或者直接給 ID（英文+數字+底線+減號的組合）';
      }
    }

    return null;
  }

  /// [_validator] make sure [text] is not null
  String? formatter(String? text) {
    final urlResult = RegExp(urlRegex).firstMatch(text!);

    if (urlResult != null) {
      return urlResult.group(1);
    }

    return RegExp(idRegex).firstMatch(text)?.group(0);
  }

  final id = await showDialog<String>(
    context: context,
    builder: (context) {
      return SingleTextDialog(
        header: CachedNetworkImage(
          imageUrl:
              "https://raw.githubusercontent.com/evan361425/flutter-pos-system/master/assets/web/tutorial-gs-copy-url.gif",
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
        ),
        initialValue: origin?.id,
        decoration: InputDecoration(
          labelText: S.exporterGSSpreadsheetLabel,
          helperText: origin?.name == null
              ? '輸入試算表網址或試算表 ID'
              : '該試算表名稱為「${origin?.name}」',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          errorMaxLines: 5,
        ),
        autofocus: false,
        selectAll: true,
        validator: validator,
        formatter: formatter,
      );
    },
  );

  if (id == null) return null;

  final result = await exporter.getSpreadsheet(id);
  if (result == null) {
    showErrorSnackbar(context, '找不到該表單，是否沒開放權限讀取？');
  }
  return result;
}
